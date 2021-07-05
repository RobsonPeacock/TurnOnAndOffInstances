require 'aws-sdk-autoscaling'
require 'aws-sdk-rds'
require 'aws-sdk-ec2'
require 'aws-sdk-route53'

#Turn on any RDS instances that are passed into the turn_on_rds_instances method
def lambda_handler(instances)
  turn_on_asg()
  turn_on_bastion()
  turn_on_rds_instances()
end

def turn_on_bastion()
  #Instantiate EC2 Client
  ec2_client = Aws::EC2::Client.new
  ec2_resource = Aws::EC2::Resource.new
  route53_client = Aws::Route53::Client.new

  ec2_client.start_instances({instance_ids: ["enter_instance_id"]})
  bastion_ip = ec2_resource.instances.find{|e| e.tags.first.value == 'bastion' }.public_ip_address
  route53_client.change_resource_record_sets({hosted_zone_id: 'enter_hosted_zone_id', change_batch: { changes: [{action: 'UPSERT', resource_record_set: {name: 'enter_domain', resource_records: [{value: bastion_ip}], type: 'enter_type', ttl: 'enter_ttl_value'}}]}})
end

def turn_on_asg()
  #Instantiate ASG Client
  asg_client = Aws::AutoScaling::Client.new

  ['enter_asg_value', 'enter_asg_value'].each{|a| asg_client.resume_processes({auto_scaling_group_name: a}) }
end

def turn_on_rds_instances()
  #Instantiate RDS Client
  rds_client = Aws::RDS::Client.new

  #Instantiate RDS resource
  rds_resource = Aws::RDS::Resource.new

  instances = rds_resource.db_instances.select{ |instance| ['enter_db_instance_name'].include?(instance.db_instance_identifier) }

  instances.each do |instance|
    Aws::RDS::Client.new.start_db_instance({:db_instance_identifier => instance.db_instance_identifier})
  end
end
