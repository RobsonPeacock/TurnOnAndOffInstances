require 'aws-sdk-autoscaling'
require 'aws-sdk-rds'
require 'aws-sdk-ec2'

def lambda_handler()
  turn_off_rds_instances
  turn_off_bastion
  turn_off_asg
  terminate_ec2_instances
end

def turn_off_rds_instances
  #Instantiate RDS Client
  rds_client = Aws::RDS::Client.new

  #Instantiate RDS resource
  rds_resource = Aws::RDS::Resource.new

  instances = rds_resource.db_instances.select{ |instance| instance.db_instance_status == 'available' }

  instances.each do |instance|
    rds_client.stop_db_instance({:db_instance_identifier => instance.db_instance_identifier})
  end
end

def turn_off_bastion
  #Instantiate EC2 Client
  ec2_client = Aws::EC2::Client.new

  #Instantiate EC2 Resource
  ec2_resource = Aws::EC2::Resource.new

  ec2_client.stop_instances({instance_ids: ["enter_instance_id"]})
end

def turn_off_asg
  #Instantiate ASG Client
  asg_client = Aws::AutoScaling::Client.new

  ['enter_asg_name', 'enter_asg_name'].each{|a| asg_client.suspend_processes({auto_scaling_group_name: a, scaling_processes: ['Launch']}) }
end

def terminate_ec2_instances
  #Instantiate EC2 Client
  ec2_client = Aws::EC2::Client.new

  #Instantiate EC2 Resource
  ec2_resource = Aws::EC2::Resource.new

  instance_ids = ec2_resource.instances.select{|instance| ['enter_instance_name', 'enter_instance_name'].include?(instance.tags.find{|e| e.key == 'Name' }.value)}.map{|instance| instance.id }

  ec2_client.terminate_instances({instance_ids: instance_ids})
end
