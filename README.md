# Clickhouse on EC2 using terraform

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed**

## Deployment Steps

### 1. Initialize Terraform

```bash
git clone https://github.com/synacktraa/ubuntu-on-ec2-using-tf.git
cd ubuntu-on-ec2-using-tf
terraform init
```

### 2. Create Keys

```bash
ssh-keygen -t rsa -b 4096 -f ec2-ubuntu
```

### 3. Apply the Configuration

```bash
terraform apply
```

#### Variables

- `instance_type` - Change Instance's type (Default: `t3.small`)
- `volume_size` - Modify storage size of the device (Default: `20gb`)
- `allowed_cidr_blocks` - Restrict access to certain IPs (Default: `0.0.0.0/0`)

Type `yes` when prompted to confirm the deployment.

### 4. Get Outputs

After deployment, get the connection details:

```bash
terraform output
```

## Accessing the instance via SSH Tunnel

```bash
$(terraform output -raw ssh_command)
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm destruction.

## Troubleshooting

1. Verify security group rules allow your IP
