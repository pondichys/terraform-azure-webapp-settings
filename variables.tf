locals {
    common_tags = {
    appOwner   = "Cloud Team"
    costCenter  = "Cloud"
    projectCode = "1337"
    }
    
    whp_config_file = "./config.yml"
    whp_config_file_content = fileexists(local.whp_config_file) ? file(local.whp_config_file) : "NoSettingsFileFound: true"
    webapp = yamldecode(local.whp_config_file_content)["webapp"]
}