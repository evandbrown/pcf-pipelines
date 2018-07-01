#!/bin/bash

set -eu

iaas_configuration=$(
  jq -n \
    --arg gcp_project "$GCP_PROJECT_ID" \
    --arg default_deployment_tag "$GCP_RESOURCE_PREFIX" \
    --arg auth_json "$GCP_SERVICE_ACCOUNT_KEY" \
    '
    {
      "project": $gcp_project,
      "default_deployment_tag": $default_deployment_tag,
      "auth_json": $auth_json
    }
    '
)

availability_zones="${GCP_ZONE_1},${GCP_ZONE_2},${GCP_ZONE_3}"

az_configuration=$(
  jq -n \
    --arg availability_zones "$availability_zones" \
    '$availability_zones | split(",") | map({name: .})'
)

pushd terraform-state
  output_json=$(terraform output -json -state=terraform.tfstate)
  network_project=$(echo $output_json | jq --raw-output '.host_network_project.value')
  network_name=$(echo $output_json | jq --raw-output '.network_name.value')
  network_region=$(echo $output_json | jq --raw-output '.region.value')

  infra_vcenter_network="${network_project}/${network_name}/$(echo $output_json | jq -r '.ops_manager_subnet.value')/${network_region}"
  infra_vcenter_network_cidr=$(echo $output_json | jq -r '.ops_manager_cidr.value')
  infra_vcenter_network_gateway=$(echo $output_json | jq -r '.ops_manager_gateway.value')

  deployment_vcenter_network="${network_project}/${network_name}/$(echo $output_json | jq -r '.ert_subnet.value')/${network_region}"
  deployment_vcenter_network_cidr=$(echo $output_json | jq -r '.ert_cidr.value')
  deployment_vcenter_network_gateway=$(echo $output_json | jq -r '.ert_gateway.value')


  services_vcenter_network="${network_project}/${network_name}/$(echo $output_json | jq -r '.svc_net_1_subnet.value')/${network_region}"
  services_vcenter_network_cidr=$(echo $output_json | jq -r '.svc_net_1_cidr.value')
  services_vcenter_network_gateway=$(echo $output_json | jq -r '.svc_net_1_gateway.value')

  dynamic_services_vcenter_network="${network_project}/${network_name}/$(echo $output_json | jq -r '.dynamic_svc_net_1_subnet.value')/${network_region}"
  dynamic_services_vcenter_network_cidr=$(echo $output_json | jq -r '.dynamic_svc_net_1_cidr.value')
  dynamic_services_vcenter_network_gateway=$(echo $output_json | jq -r '.dynamic_svc_net_1_gateway.value')
popd

network_configuration=$(
  jq -n \
    --argjson icmp_checks_enabled false \
    --arg infra_network_name "infrastructure" \
    --arg infra_vcenter_network "${infra_vcenter_network}" \
    --arg infra_network_cidr "${infra_vcenter_network_cidr}" \
    --arg infra_dns "${infra_vcenter_network_gateway},8.8.8.8" \
    --arg infra_gateway "${infra_vcenter_network_gateway}" \
    --arg infra_availability_zones "$availability_zones" \
    --arg deployment_network_name "ert" \
    --arg deployment_vcenter_network "${deployment_vcenter_network}" \
    --arg deployment_network_cidr "${deployment_vcenter_network_cidr}" \
    --arg deployment_dns "${deployment_vcenter_network_gateway},8.8.8.8" \
    --arg deployment_gateway "${deployment_vcenter_network_gateway}" \
    --arg deployment_availability_zones "$availability_zones" \
    --arg services_network_name "services-1" \
    --arg services_vcenter_network "${services_vcenter_network}" \
    --arg services_network_cidr "${services_vcenter_network_cidr}" \
    --arg services_dns "${services_vcenter_network_gateway},8.8.8.8" \
    --arg services_gateway "${services_vcenter_network_gateway}" \
    --arg services_availability_zones "$availability_zones" \
    --arg dynamic_services_network_name "dynamic-services-1" \
    --arg dynamic_services_vcenter_network "${dynamic_services_vcenter_network}" \
    --arg dynamic_services_network_cidr "${dynamic_services_vcenter_network_cidr}" \
    --arg dynamic_services_dns "${dynamic_services_vcenter_network_gateway},8.8.8.8" \
    --arg dynamic_services_gateway "${dynamic_services_vcenter_network_gateway}" \
    --arg dynamic_services_availability_zones "$availability_zones" \
    '
    {
      "icmp_checks_enabled": $icmp_checks_enabled,
      "networks": [
        {
          "name": $infra_network_name,
          "service_network": false,
          "subnets": [
            {
              "iaas_identifier": $infra_vcenter_network,
              "cidr": $infra_network_cidr,
              "dns": $infra_dns,
              "gateway": $infra_gateway,
              "availability_zone_names": ($infra_availability_zones | split(","))
            }
          ]
        },
        {
          "name": $deployment_network_name,
          "service_network": false,
          "subnets": [
            {
              "iaas_identifier": $deployment_vcenter_network,
              "cidr": $deployment_network_cidr,
              "dns": $deployment_dns,
              "gateway": $deployment_gateway,
              "availability_zone_names": ($deployment_availability_zones | split(","))
            }
          ]
        },
        {
          "name": $services_network_name,
          "service_network": false,
          "subnets": [
            {
              "iaas_identifier": $services_vcenter_network,
              "cidr": $services_network_cidr,
              "dns": $services_dns,
              "gateway": $services_gateway,
              "availability_zone_names": ($services_availability_zones | split(","))
            }
          ]
        },
        {
          "name": $dynamic_services_network_name,
          "service_network": true,
          "subnets": [
            {
              "iaas_identifier": $dynamic_services_vcenter_network,
              "cidr": $dynamic_services_network_cidr,
              "dns": $dynamic_services_dns,
              "gateway": $dynamic_services_gateway,
              "availability_zone_names": ($dynamic_services_availability_zones | split(","))
            }
          ]
        }
      ]
    }'
)

director_config=$(cat <<-EOF
{
  "ntp_servers_string": "0.pool.ntp.org",
  "resurrector_enabled": true,
  "retry_bosh_deploys": true,
  "database_type": "internal",
  "blobstore_type": "local"
}
EOF
)

resource_configuration=$(cat <<-EOF
{
  "director": {
    "internet_connected": false
  },
  "compilation": {
    "internet_connected": false
  }
}
EOF
)

security_configuration=$(
  jq -n \
    --arg trusted_certificates "$OPS_MGR_TRUSTED_CERTS" \
    '
    {
      "trusted_certificates": $trusted_certificates,
      "vm_password_type": "generate"
    }'
)

network_assignment=$(
  jq -n \
    --arg availability_zones "$availability_zones" \
    --arg network "infrastructure" \
    '
    {
      "singleton_availability_zone": {
        "name": ($availability_zones | split(",") | .[0])
      },
      "network": {
        "name": $network
      }
    }'
)

echo "Configuring IaaS and Director..."
om-linux \
  --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
  --skip-ssl-validation \
  --username "$OPS_MGR_USR" \
  --password "$OPS_MGR_PWD" \
  configure-director \
  --iaas-configuration "$iaas_configuration" \
  --director-configuration "$director_config" \
  --az-configuration "$az_configuration" \
  --networks-configuration "$network_configuration" \
  --network-assignment "$network_assignment" \
  --security-configuration "$security_configuration" \
  --resource-configuration "$resource_configuration"
