# DevOps Commands Bible

## 1. Linux

| Command | Description | Explanation |
|---|---|---|
| `lsblk -f` | List block devices with filesystems | Shows filesystem types, labels, UUIDs for all block devices. |
| `df -h` | Display disk space usage | Human-readable filesystem space utilization across all mounts. |
| `du -sh ${DIR}` | Show directory size | Calculates total size of specified directory recursively. |
| `free -m` | Display memory usage in MB | Shows total, used, free, shared, cache/buffer memory. |
| `top` | Interactive process viewer | Real-time system monitoring of CPU, memory, processes. |
| `htop` | Enhanced interactive process viewer | Color-coded, user-friendly alternative to top with scrolling. |
| `ps aux` | List all running processes | Full process list with user, CPU, memory details. |
| `ps -ef --forest` | Show process tree | Hierarchical view of parent-child process relationships. |
| `kill -9 ${PID}` | Force kill process [DANGER] | Immediately terminates process without cleanup; use cautiously. |
| `killall ${PROCESS_NAME}` | Kill processes by name | Terminates all processes matching the given name. |
| `systemctl status ${SERVICE}` | Check service status | Shows active state, PID, memory usage of systemd service. |
| `systemctl start ${SERVICE}` | Start systemd service | Activates service immediately without enabling at boot. |
| `systemctl stop ${SERVICE}` | Stop systemd service | Gracefully halts running systemd service. |
| `systemctl restart ${SERVICE}` | Restart systemd service | Stops then starts service; applies configuration changes. |
| `systemctl enable ${SERVICE}` | Enable service at boot | Configures service to start automatically on system boot. |
| `systemctl disable ${SERVICE}` | Disable service at boot | Prevents service from starting automatically on boot. |
| `journalctl -u ${SERVICE}` | View service logs | Displays systemd journal logs for specific service. |
| `journalctl -f` | Follow system logs live | Real-time streaming of systemd journal entries. |
| `journalctl --since "1 hour ago"` | Show recent logs | Filters journal entries from last hour onwards. |
| `useradd -m ${USER}` | Create user with home dir | Adds new user account with home directory. |
| `usermod -aG ${GROUP} ${USER}` | Add user to group | Appends user to supplementary group without removing existing. |
| `passwd ${USER}` | Change user password | Interactive password update for specified user account. |
| `groupadd ${GROUP}` | Create new group | Adds new system or user group. |
| `chown ${USER}:${GROUP} ${FILE}` | Change file ownership | Sets user and group ownership of file/directory. |
| `chmod 755 ${FILE}` | Set file permissions | Assigns rwxr-xr-x permissions to file or directory. |
| `chmod +x ${FILE}` | Make file executable | Adds execute permission for all users. |
| `tar -czf ${ARCHIVE}.tar.gz ${DIR}` | Create compressed archive | Compresses directory into gzip tarball for backup/transfer. |
| `tar -xzf ${ARCHIVE}.tar.gz` | Extract gzip archive | Decompresses and extracts tarball to current directory. |
| `ssh ${USER}@${HOST}` | SSH to remote host | Establishes secure shell connection to remote server. |
| `scp ${FILE} ${USER}@${HOST}:${PATH}` | Secure copy to remote | Transfers file to remote host via SSH. |
| `rsync -avz ${SRC} ${DEST}` | Sync files efficiently | Copies only changed files with compression and archives. |
| `netstat -tuln` | List listening ports | Shows TCP/UDP ports listening for incoming connections. |
| `ss -tuln` | Modern socket statistics | Faster alternative to netstat for port listening info. |
| `ip addr show` | Display network interfaces | Shows all IP addresses assigned to network interfaces. |
| `ip route show` | Display routing table | Lists all routes with gateway and interface information. |
| `iptables -L -n` | List firewall rules | Displays current iptables rules without DNS resolution. |
| `ufw allow ${PORT}` | [Ubuntu] Allow firewall port | Opens specified port through Ubuntu UFW firewall. |
| `ufw status` | [Ubuntu] Check firewall status | Shows UFW enabled/disabled state and active rules. |
| `firewall-cmd --list-all` | [RHEL] List firewall config | Displays zones, services, ports for firewalld. |
| `firewall-cmd --add-port=${PORT}/tcp --permanent` | [RHEL] Open port permanently | Adds port to firewalld and reloads configuration. |
| `systemctl status firewalld` | [RHEL] Check firewalld status | Shows firewalld service state and activity. |
| `dmesg | tail -50` | Show recent kernel messages | Displays last 50 kernel ring buffer messages. |
| `lsof -i :${PORT}` | List processes on port | Identifies which process is using specified port. |
| `strace -p ${PID}` | Trace system calls | Monitors syscalls and signals for debugging process. |
| `tcpdump -i ${IFACE} port ${PORT}` | Capture network packets | Sniffs packets on interface for network troubleshooting. |
| `find / -name ${FILE} 2>/dev/null` | Search file system-wide | Locates files by name, suppressing permission errors. |
| `grep -r "${PATTERN}" ${DIR}` | Recursively search in files | Searches for text pattern in all files. |
| `tail -f ${FILE}` | Follow file updates live | Continuously displays new lines appended to file. |
| `head -n 20 ${FILE}` | Show first 20 lines | Displays beginning of file for quick preview. |
| `cat ${FILE}` | Display file contents | Outputs entire file content to stdout. |
| `less ${FILE}` | Paginated file viewer | Allows scrolling through file with search capability. |
| `ln -s ${TARGET} ${LINK}` | Create symbolic link | Makes symlink pointing to target file/directory. |
| `mount /dev/${DEVICE} ${MOUNTPOINT}` | Mount filesystem | Attaches device filesystem to directory tree. |
| `umount ${MOUNTPOINT}` | Unmount filesystem | Detaches mounted filesystem from directory tree. |
| `fdisk -l` | List disk partitions | Shows all disk partitions with sizes and types. |
| `mkfs.ext4 /dev/${DEVICE}` | Format as ext4 [DANGER] | Creates ext4 filesystem, destroying existing data. |
| `swapon /dev/${DEVICE}` | Enable swap partition | Activates swap space for virtual memory. |
| `crontab -e` | Edit cron schedule | Opens crontab for scheduling recurring tasks. |
| `at now + 1 hour` | Schedule one-time task | Queues command to run once at future time. |
| `watch -n 2 ${COMMAND}` | Repeat command every 2s | Continuously executes command with interval display. |
| `hostname -I` | Show IP addresses | Displays all IP addresses assigned to host. |
| `uptime` | Show system uptime | Reports how long system has been running. |
| `who` | Show logged in users | Lists current users connected to system. |
| `last -n 10` | Show recent logins | Displays last 10 user login/logout events. |

## 2. Bash

| Command | Description | Explanation |
|---|---|---|
| `set -e` | Exit on error | Stops script execution immediately when any command fails. |
| `set -u` | Exit on undefined variable | Terminates script if referencing unset variable. |
| `set -x` | Enable debug trace | Prints each command before execution for debugging. |
| `set -o pipefail` | Fail on pipe errors | Returns failure if any command in pipeline fails. |
| `set -euxo pipefail` | Strict error mode | Combines all safety flags for robust script execution. |
| `${VAR:-default}` | Variable with default | Returns default if VAR unset or empty. |
| `${VAR:=default}` | Assign default if unset | Sets VAR to default if unset, then returns. |
| `${VAR:?error}` | Require variable or fail | Exits with error message if VAR unset. |
| `${#VAR}` | Variable length | Returns character count of string variable. |
| `${VAR#pattern}` | Remove shortest prefix | Strips shortest matching prefix from variable. |
| `${VAR##pattern}` | Remove longest prefix | Strips longest matching prefix from variable. |
| `${VAR%pattern}` | Remove shortest suffix | Strips shortest matching suffix from variable. |
| `${VAR%%pattern}` | Remove longest suffix | Strips longest matching suffix from variable. |
| `arr=(a b c)` | Declare array | Creates indexed array with three elements. |
| `${arr[@]}` | Expand all elements | Returns all array elements as separate words. |
| `${#arr[@]}` | Array length | Returns count of elements in array. |
| `for i in {1..10}; do echo $i; done` | Numeric range loop | Iterates from 1 to 10 printing each. |
| `for file in *.txt; do echo $file; done` | Glob pattern loop | Iterates over all txt files in directory. |
| `while read line; do echo $line; done < ${FILE}` | Read file line by line | Processes each line from file in loop. |
| `if [[ -f ${FILE} ]]; then echo "exists"; fi` | Check file exists | Tests if file exists and is regular file. |
| `if [[ -d ${DIR} ]]; then echo "exists"; fi` | Check directory exists | Tests if directory exists. |
| `if [[ -z "${VAR}" ]]; then echo "empty"; fi` | Check string empty | Tests if variable is empty or unset. |
| `if [[ "${VAR}" =~ ^[0-9]+$ ]]; then echo "number"; fi` | Regex match test | Checks if variable matches numeric pattern. |
| `command > ${FILE}` | Redirect stdout | Writes command output to file, overwriting existing. |
| `command >> ${FILE}` | Append stdout | Appends command output to file without overwriting. |
| `command 2>&1` | Redirect stderr to stdout | Combines error output with standard output stream. |
| `command &> ${FILE}` | Redirect both streams | Writes both stdout and stderr to file. |
| `command1 | command2` | Pipe output | Sends stdout of command1 to stdin of command2. |
| `cat <<EOF > ${FILE}\ntext\nEOF` | Here-document | Creates file with multi-line content using heredoc. |
| `cat <<-EOF\n\ttext\nEOF` | Here-doc strip tabs | Heredoc that removes leading tabs from lines. |
| `command <<< "string"` | Here-string | Passes string as stdin to command. |
| `$(command)` | Command substitution | Captures command output as string for use. |
| `` `command` `` | Command substitution legacy | Older backtick syntax for command substitution. |
| `func() { echo "$1"; }` | Define function | Creates reusable function accepting parameters. |
| `local var="value"` | Local variable | Declares variable scoped to function only. |
| `trap 'cleanup' EXIT` | Run on exit | Executes cleanup function when script exits. |
| `trap 'error_handler' ERR` | Run on error | Triggers error handler when command fails. |
| `(command)` | Subshell execution | Runs command in isolated subprocess environment. |
| `{ command; }` | Group commands | Executes commands in current shell grouping. |
| `command &` | Background job | Runs command in background, returns control immediately. |
| `wait ${PID}` | Wait for background job | Blocks until specified background process completes. |
| `jobs` | List background jobs | Shows active background jobs in current shell. |
| `fg %1` | Bring job to foreground | Resumes job 1 in foreground. |
| `echo "${VAR}" | jq .` | Parse JSON with jq | Pipes JSON variable through jq for formatting/querying. |
| `yq eval '.key' ${FILE}` | Parse YAML with yq | Extracts value from YAML file using key path. |
| `source ${FILE}` | Execute in current shell | Loads script in current context, preserving variables. |
| `. ${FILE}` | Source script shorthand | Dot notation for sourcing file in shell. |
| `export VAR=value` | Export environment variable | Makes variable available to child processes. |
| `env` | List environment variables | Shows all exported environment variables. |
| `basename ${PATH}` | Extract filename | Returns filename from full path string. |
| `dirname ${PATH}` | Extract directory | Returns directory portion of path string. |
| `mktemp` | Create temp file | Generates unique temporary file safely. |
| `mktemp -d` | Create temp directory | Generates unique temporary directory safely. |

## 3. Git & GitHub

| Command | Description | Explanation |
|---|---|---|
| `git init` | Initialize repository | Creates new Git repository in current directory. |
| `git clone ${REPO}` | Clone repository | Downloads remote repository to local machine. |
| `git status` | Show working tree status | Displays modified, staged, untracked files. |
| `git add ${FILE}` | Stage file changes | Adds file modifications to staging area. |
| `git add .` | Stage all changes | Adds all modified/new files to staging. |
| `git commit -m "${MESSAGE}"` | Commit with message | Records staged changes with description. |
| `git commit --amend` | Amend last commit | Modifies most recent commit message or content. |
| `git push origin ${BRANCH}` | Push to remote branch | Uploads local commits to remote repository. |
| `git pull` | Fetch and merge | Downloads and integrates remote changes to current branch. |
| `git fetch` | Download remote refs | Retrieves remote changes without merging them. |
| `git branch` | List local branches | Shows all branches with current marked. |
| `git branch ${BRANCH}` | Create new branch | Creates branch at current commit. |
| `git checkout ${BRANCH}` | Switch branches | Changes working tree to specified branch. |
| `git checkout -b ${BRANCH}` | Create and switch branch | Creates new branch and immediately switches to it. |
| `git merge ${BRANCH}` | Merge branch | Integrates specified branch into current branch. |
| `git rebase ${BRANCH}` | Rebase onto branch | Reapplies commits on top of another base. |
| `git rebase -i HEAD~3` | Interactive rebase 3 commits | Allows editing, squashing, reordering last 3 commits. |
| `git stash` | Stash working changes | Saves uncommitted changes for later restoration. |
| `git stash pop` | Apply and drop stash | Restores stashed changes and removes from stash. |
| `git stash list` | List stashed changes | Shows all saved stash entries. |
| `git log --oneline -10` | Show last 10 commits | Displays recent commit history condensed. |
| `git log --graph --all` | Visualize branch history | Shows commit graph with all branches. |
| `git diff` | Show unstaged changes | Displays modifications not yet staged. |
| `git diff --staged` | Show staged changes | Displays modifications in staging area. |
| `git reset HEAD ${FILE}` | Unstage file | Removes file from staging area. |
| `git reset --hard HEAD` | Discard all changes [DANGER] | Reverts working tree to last commit state. |
| `git reset --soft HEAD~1` | Undo last commit keep changes | Moves HEAD back but preserves changes staged. |
| `git cherry-pick ${COMMIT}` | Apply specific commit | Copies commit from another branch to current. |
| `git bisect start` | Start binary search | Initiates bisect to find bug-introducing commit. |
| `git bisect bad` | Mark commit as bad | Labels current commit as containing bug. |
| `git bisect good ${COMMIT}` | Mark commit as good | Labels commit as not containing bug. |
| `git tag ${TAG}` | Create tag | Marks current commit with tag name. |
| `git tag -a ${TAG} -m "${MSG}"` | Create annotated tag | Creates tag with metadata and message. |
| `git push origin ${TAG}` | Push tag to remote | Uploads tag to remote repository. |
| `git remote -v` | List remotes | Shows configured remote repositories with URLs. |
| `git remote add ${NAME} ${URL}` | Add remote | Configures new remote repository reference. |
| `git clean -fd` | Remove untracked files [DANGER] | Deletes untracked files and directories forcefully. |
| `git config --global user.name "${NAME}"` | Set user name | Configures Git author name globally. |
| `git config --global user.email "${EMAIL}"` | Set user email | Configures Git author email globally. |
| `git commit -S -m "${MSG}"` | Sign commit with GPG | Creates GPG-signed commit for verification. |
| `gh repo list ${OWNER}` | List GitHub repos | Shows repositories for user or org. |
| `gh repo create ${REPO}` | Create GitHub repository | Makes new repository on GitHub. |
| `gh issue list` | List repository issues | Shows open issues in current repo. |
| `gh issue create` | Create new issue | Opens interactive prompt to create issue. |
| `gh pr list` | List pull requests | Shows open PRs in current repository. |
| `gh pr create` | Create pull request | Opens interactive prompt to create PR. |
| `gh pr checkout ${NUMBER}` | Checkout PR branch | Switches to PR branch locally. |
| `gh pr merge ${NUMBER}` | Merge pull request | Merges specified PR on GitHub. |
| `gh release list` | List releases | Shows published releases for repository. |
| `gh release create ${TAG}` | Create release | Publishes new release with tag. |

## 4. AWS (CLI)

| Command | Description | Explanation |
|---|---|---|
| `aws configure` | Configure AWS credentials | Interactive setup of access keys and region. |
| `aws configure list` | Show current config | Displays active credentials and region settings. |
| `aws sts get-caller-identity` | Verify AWS identity | Shows current user/role ARN and account ID. |
| `aws sts assume-role --role-arn ${ARN} --role-session-name ${NAME}` | Assume IAM role | Obtains temporary credentials for cross-account access. |
| `aws s3 ls` | List S3 buckets | Shows all buckets in account. |
| `aws s3 ls s3://${BUCKET}/` | List bucket contents | Shows objects in specified S3 bucket. |
| `aws s3 cp ${FILE} s3://${BUCKET}/` | Upload to S3 | Copies local file to S3 bucket. |
| `aws s3 cp s3://${BUCKET}/${KEY} ${FILE}` | Download from S3 | Copies S3 object to local filesystem. |
| `aws s3 sync ${DIR} s3://${BUCKET}/` | Sync directory to S3 | Uploads only changed files to bucket. |
| `aws s3 rm s3://${BUCKET}/${KEY}` | Delete S3 object | Removes object from bucket. |
| `aws s3 mb s3://${BUCKET}` | Create S3 bucket | Makes new bucket in default region. |
| `aws s3 rb s3://${BUCKET} --force` | Delete bucket [DANGER] | Removes bucket and all contents forcefully. |
| `aws ec2 describe-instances` | List EC2 instances | Shows all instances with status and details. |
| `aws ec2 describe-instances --filters "Name=tag:Name,Values=${NAME}"` | Filter instances by tag | Shows instances matching specific tag value. |
| `aws ec2 start-instances --instance-ids ${ID}` | Start EC2 instance | Powers on stopped instance. |
| `aws ec2 stop-instances --instance-ids ${ID}` | Stop EC2 instance | Gracefully shuts down running instance. |
| `aws ec2 terminate-instances --instance-ids ${ID}` | Terminate instance [DANGER] | Permanently destroys EC2 instance and data. |
| `aws ec2 describe-security-groups` | List security groups | Shows all VPC security groups and rules. |
| `aws ec2 describe-vpcs` | List VPCs | Shows all VPCs in region. |
| `aws ec2 describe-subnets` | List subnets | Shows all subnets across VPCs. |
| `aws iam list-users` | List IAM users | Shows all users in account. |
| `aws iam list-roles` | List IAM roles | Shows all roles with ARNs. |
| `aws iam get-user` | Get current user | Shows details of authenticated IAM user. |
| `aws iam create-user --user-name ${USER}` | Create IAM user | Adds new user to account. |
| `aws iam attach-user-policy --user-name ${USER} --policy-arn ${ARN}` | Attach policy to user | Grants permissions via managed policy. |
| `aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com` | Login to ECR | Authenticates Docker to push/pull ECR images. |
| `aws ecr create-repository --repository-name ${REPO}` | Create ECR repository | Makes new container registry repository. |
| `aws ecr describe-repositories` | List ECR repositories | Shows all container registries in account. |
| `aws eks list-clusters` | List EKS clusters | Shows all Kubernetes clusters in region. |
| `aws eks describe-cluster --name ${CLUSTER}` | Get EKS cluster details | Shows configuration and status of cluster. |
| `aws eks update-kubeconfig --name ${CLUSTER}` | Configure kubectl for EKS | Adds EKS cluster context to kubeconfig. |
| `aws logs tail /aws/lambda/${FUNCTION} --follow` | Follow Lambda logs | Streams CloudWatch logs for function in real-time. |
| `aws logs describe-log-groups` | List log groups | Shows all CloudWatch log groups. |
| `aws logs filter-log-events --log-group-name ${GROUP} --filter-pattern "${PATTERN}"` | Search CloudWatch logs | Queries logs matching filter pattern. |
| `aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=${ID} --start-time ${START} --end-time ${END} --period 300 --statistics Average` | Get CloudWatch metrics | Retrieves metric datapoints for specified period. |
| `aws kms list-keys` | List KMS keys | Shows all encryption keys in account. |
| `aws kms encrypt --key-id ${KEY_ID} --plaintext "${TEXT}"` | Encrypt with KMS | Encrypts data using KMS key. |
| `aws kms decrypt --ciphertext-blob ${BLOB}` | Decrypt with KMS | Decrypts KMS-encrypted data. |
| `aws lambda list-functions` | List Lambda functions | Shows all functions in region. |
| `aws lambda invoke --function-name ${FUNCTION} output.json` | Invoke Lambda function | Executes function and saves response. |
| `aws rds describe-db-instances` | List RDS instances | Shows all database instances with status. |
| `aws route53 list-hosted-zones` | List Route53 zones | Shows all DNS hosted zones. |
| `aws cloudformation list-stacks` | List CloudFormation stacks | Shows all stacks with current status. |
| `aws cloudformation describe-stacks --stack-name ${STACK}` | Get stack details | Shows resources and outputs of stack. |

## 5. Terraform

| Command | Description | Explanation |
|---|---|---|
| `terraform init` | Initialize working directory | Downloads providers and prepares backend for work. |
| `terraform validate` | Validate configuration | Checks syntax and internal consistency of config. |
| `terraform fmt` | Format configuration | Auto-formats code to canonical style. |
| `terraform fmt -check` | Check formatting | Returns error if files need formatting. |
| `terraform plan` | Preview changes | Shows what resources will be created/modified/destroyed. |
| `terraform plan -out=${FILE}` | Save plan to file | Generates plan file for later apply. |
| `terraform apply` | Apply changes | Creates/updates infrastructure per configuration. |
| `terraform apply -auto-approve` | Apply without prompt [DANGER] | Skips confirmation; use in automation only. |
| `terraform apply ${FILE}` | Apply saved plan | Executes previously saved plan file. |
| `terraform destroy` | Destroy all resources [DANGER] | Deletes all managed infrastructure permanently. |
| `terraform destroy -auto-approve` | Destroy without prompt [DANGER] | Deletes everything without confirmation; extremely risky. |
| `terraform show` | Show current state | Displays human-readable state or plan output. |
| `terraform state list` | List resources in state | Shows all resources tracked in state. |
| `terraform state show ${RESOURCE}` | Show resource state | Displays detailed state for specific resource. |
| `terraform state mv ${SRC} ${DEST}` | Rename resource in state | Moves resource to new address without recreating. |
| `terraform state rm ${RESOURCE}` | Remove from state | Stops managing resource but doesn't destroy it. |
| `terraform state pull` | Download remote state | Retrieves state from backend to stdout. |
| `terraform state push ${FILE}` | Upload state [DANGER] | Forces state to backend; risks corruption. |
| `terraform import ${RESOURCE} ${ID}` | Import existing resource | Adds existing infrastructure to state management. |
| `terraform taint ${RESOURCE}` | Mark resource for recreation | Forces replacement on next apply. |
| `terraform untaint ${RESOURCE}` | Remove taint mark | Cancels planned recreation of resource. |
| `terraform refresh` | Update state from real | Syncs state with actual infrastructure without changes. |
| `terraform output` | Show all outputs | Displays output values from configuration. |
| `terraform output ${NAME}` | Show specific output | Returns value of named output. |
| `terraform workspace list` | List workspaces | Shows all available workspaces with active marked. |
| `terraform workspace new ${NAME}` | Create workspace | Makes new isolated state environment. |
| `terraform workspace select ${NAME}` | Switch workspace | Changes to different state environment. |
| `terraform workspace delete ${NAME}` | Delete workspace | Removes workspace after switching away. |
| `terraform graph` | Generate dependency graph | Outputs DOT format graph of resources. |
| `terraform console` | Interactive console | Opens REPL for testing expressions. |
| `terraform providers` | List required providers | Shows providers and versions from configuration. |
| `terraform version` | Show Terraform version | Displays CLI and provider versions. |
| `terraform force-unlock ${LOCK_ID}` | Force unlock state [DANGER] | Removes stuck state lock; coordinate with team. |
| `terraform get` | Download modules | Fetches modules referenced in configuration. |
| `terraform login` | Login to Terraform Cloud | Authenticates for remote operations. |

## 6. Ansible

| Command | Description | Explanation |
|---|---|---|
| `ansible --version` | Show Ansible version | Displays version and config file location. |
| `ansible all -m ping` | Ping all hosts | Tests connectivity to inventory hosts. |
| `ansible ${HOST} -m shell -a "${CMD}"` | Run ad-hoc shell command | Executes command on specified host/group. |
| `ansible ${GROUP} -m copy -a "src=${SRC} dest=${DEST}"` | Copy file to hosts | Transfers file to target hosts. |
| `ansible ${HOST} -m file -a "path=${PATH} state=absent"` | Delete file on host | Removes file or directory remotely. |
| `ansible ${HOST} -m service -a "name=${SERVICE} state=restarted"` | Restart service | Restarts systemd service on host. |
| `ansible ${HOST} -m apt -a "name=${PKG} state=present"` | [Ubuntu] Install package | Installs package via apt on Debian systems. |
| `ansible ${HOST} -m yum -a "name=${PKG} state=present"` | [RHEL] Install package | Installs package via yum on RedHat systems. |
| `ansible-playbook ${PLAYBOOK}.yml` | Run playbook | Executes Ansible playbook against inventory. |
| `ansible-playbook ${PLAYBOOK}.yml --check` | Dry-run playbook | Simulates changes without applying them. |
| `ansible-playbook ${PLAYBOOK}.yml --diff` | Show differences | Displays file changes during playbook run. |
| `ansible-playbook ${PLAYBOOK}.yml --syntax-check` | Validate syntax | Checks playbook for YAML/syntax errors. |
| `ansible-playbook ${PLAYBOOK}.yml --list-hosts` | Show target hosts | Lists hosts that would be affected. |
| `ansible-playbook ${PLAYBOOK}.yml --list-tasks` | List playbook tasks | Shows all tasks that would execute. |
| `ansible-playbook ${PLAYBOOK}.yml --limit ${HOST}` | Run on specific hosts | Restricts playbook execution to subset of hosts. |
| `ansible-playbook ${PLAYBOOK}.yml --tags ${TAG}` | Run tagged tasks | Executes only tasks with specified tag. |
| `ansible-playbook ${PLAYBOOK}.yml --skip-tags ${TAG}` | Skip tagged tasks | Excludes tasks with specified tag. |
| `ansible-playbook ${PLAYBOOK}.yml -e "var=value"` | Pass extra variables | Overrides variables from command line. |
| `ansible-playbook ${PLAYBOOK}.yml -vvv` | Verbose output | Shows detailed execution information for debugging. |
| `ansible-inventory --list` | List inventory | Shows parsed inventory in JSON format. |
| `ansible-inventory --graph` | Graph inventory | Displays hierarchy of groups and hosts. |
| `ansible-vault create ${FILE}` | Create encrypted file | Creates new vault-encrypted file interactively. |
| `ansible-vault edit ${FILE}` | Edit encrypted file | Opens encrypted file in editor. |
| `ansible-vault encrypt ${FILE}` | Encrypt existing file | Encrypts plaintext file with vault password. |
| `ansible-vault decrypt ${FILE}` | Decrypt vault file | Converts encrypted file to plaintext. |
| `ansible-vault view ${FILE}` | View encrypted file | Displays contents without decrypting file. |
| `ansible-playbook ${PLAYBOOK}.yml --ask-vault-pass` | Prompt for vault password | Requests vault password interactively before running. |
| `ansible-galaxy install ${ROLE}` | Install role from Galaxy | Downloads role from Ansible Galaxy. |
| `ansible-galaxy init ${ROLE}` | Create role scaffold | Generates role directory structure. |
| `ansible-galaxy list` | List installed roles | Shows roles in configured roles path. |
| `ansible ${HOST} -m setup` | Gather facts | Collects system information from host. |
| `ansible ${HOST} -m setup -a "filter=ansible_distribution*"` | Filter specific facts | Retrieves only matching fact subset. |
| `ansible-config dump` | Show configuration | Displays all config settings and sources. |
| `ansible-doc ${MODULE}` | Show module docs | Displays help for specified module. |

## 7. Kubernetes

| Command | Description | Explanation |
|---|---|---|
| `kubectl version` | Show client/server version | Displays kubectl and API server versions. |
| `kubectl cluster-info` | Show cluster info | Displays master and services endpoints. |
| `kubectl config view` | View kubeconfig | Shows merged kubeconfig from all sources. |
| `kubectl config current-context` | Show current context | Displays active cluster context name. |
| `kubectl config get-contexts` | List all contexts | Shows available cluster contexts. |
| `kubectl config use-context ${CTX}` | Switch context | Changes active cluster/namespace context. |
| `kubectl config set-context ${CTX} --namespace=${NS}` | Set default namespace | Configures namespace for context. |
| `kubectl get nodes` | List cluster nodes | Shows all nodes with status and roles. |
| `kubectl describe node ${NODE}` | Describe node details | Shows detailed node info including capacity/conditions. |
| `kubectl top nodes` | Show node metrics | Displays CPU/memory usage per node. |
| `kubectl get namespaces` | List namespaces | Shows all namespaces in cluster. |
| `kubectl create namespace ${NS}` | Create namespace | Makes new namespace for resource isolation. |
| `kubectl get pods -A` | List all pods cluster-wide | Shows pods from all namespaces. |
| `kubectl get pods -n ${NS}` | List pods in namespace | Shows pods in specific namespace. |
| `kubectl get pods -o wide` | List pods with details | Shows pod IPs and nodes. |
| `kubectl describe pod ${POD} -n ${NS}` | Describe pod details | Shows events, volumes, containers for pod. |
| `kubectl logs ${POD} -n ${NS}` | Show pod logs | Displays stdout from pod container. |
| `kubectl logs ${POD} -c ${CONTAINER} -n ${NS}` | Show container logs | Displays logs from specific container. |
| `kubectl logs -f ${POD} -n ${NS}` | Follow pod logs live | Streams logs in real-time. |
| `kubectl logs ${POD} --previous -n ${NS}` | Show previous container logs | Displays logs from crashed/restarted container. |
| `kubectl exec -it ${POD} -n ${NS} -- /bin/sh` | Interactive shell in pod | Opens shell session inside container. |
| `kubectl exec ${POD} -n ${NS} -- ${CMD}` | Run command in pod | Executes single command in container. |
| `kubectl port-forward ${POD} ${LOCAL}:${REMOTE} -n ${NS}` | Forward port to pod | Tunnels local port to pod for access. |
| `kubectl get deployments -n ${NS}` | List deployments | Shows all deployments with replicas. |
| `kubectl describe deployment ${DEPLOY} -n ${NS}` | Describe deployment | Shows detailed deployment configuration and status. |
| `kubectl scale deployment ${DEPLOY} --replicas=${NUM} -n ${NS}` | Scale deployment | Changes number of pod replicas. |
| `kubectl rollout status deployment ${DEPLOY} -n ${NS}` | Check rollout status | Shows deployment update progress. |
| `kubectl rollout history deployment ${DEPLOY} -n ${NS}` | Show rollout history | Lists deployment revision history. |
| `kubectl rollout undo deployment ${DEPLOY} -n ${NS}` | Rollback deployment | Reverts to previous deployment version. |
| `kubectl apply -f ${FILE}` | Apply manifest | Creates/updates resources from YAML file. |
| `kubectl delete -f ${FILE}` | Delete from manifest | Removes resources defined in YAML file. |
| `kubectl create -f ${FILE}` | Create from manifest | Creates resources; fails if already exists. |
| `kubectl replace -f ${FILE}` | Replace resource | Updates existing resource from file. |
| `kubectl get services -n ${NS}` | List services | Shows all services with cluster IPs. |
| `kubectl describe service ${SVC} -n ${NS}` | Describe service | Shows endpoints, selectors, ports for service. |
| `kubectl get endpoints ${SVC} -n ${NS}` | Show service endpoints | Lists pod IPs backing service. |
| `kubectl get configmaps -n ${NS}` | List config maps | Shows all configuration data objects. |
| `kubectl describe configmap ${CM} -n ${NS}` | Describe config map | Shows key-value data in configmap. |
| `kubectl get secrets -n ${NS}` | List secrets | Shows all secret objects. |
| `kubectl describe secret ${SECRET} -n ${NS}` | Describe secret | Shows secret keys without values. |
| `kubectl get pv` | List persistent volumes | Shows cluster storage volumes. |
| `kubectl get pvc -n ${NS}` | List PV claims | Shows storage claims in namespace. |
| `kubectl get ingress -n ${NS}` | List ingress rules | Shows HTTP routing rules. |
| `kubectl get events -n ${NS}` | Show namespace events | Displays recent cluster events for troubleshooting. |
| `kubectl get events --sort-by=.metadata.creationTimestamp -n ${NS}` | Show sorted events | Lists events chronologically for debugging. |
| `kubectl top pods -n ${NS}` | Show pod metrics | Displays CPU/memory usage per pod. |
| `kubectl cordon ${NODE}` | Mark node unschedulable | Prevents new pods from scheduling on node. |
| `kubectl uncordon ${NODE}` | Mark node schedulable | Allows pod scheduling on node again. |
| `kubectl drain ${NODE} --ignore-daemonsets` | Drain node for maintenance | Evicts pods before node maintenance. |
| `kubectl taint nodes ${NODE} ${KEY}=${VALUE}:NoSchedule` | Add node taint | Prevents pods without toleration from scheduling. |
| `kubectl get hpa -n ${NS}` | List autoscalers | Shows horizontal pod autoscalers. |
| `kubectl autoscale deployment ${DEPLOY} --min=${MIN} --max=${MAX} --cpu-percent=${PCT} -n ${NS}` | Create autoscaler | Configures HPA for deployment based on CPU. |
| `kubectl get pdb -n ${NS}` | List pod disruption budgets | Shows PDBs preventing mass pod eviction. |
| `kubectl get networkpolicies -n ${NS}` | List network policies | Shows network segmentation rules. |
| `kubectl auth can-i ${VERB} ${RESOURCE}` | Check RBAC permissions | Tests if current user can perform action. |
| `kubectl get roles -n ${NS}` | List roles | Shows RBAC roles in namespace. |
| `kubectl get rolebindings -n ${NS}` | List role bindings | Shows role assignments to users/groups. |
| `kubectl run ${POD} --image=${IMAGE} -n ${NS}` | Run quick pod | Creates pod from image imperatively. |
| `kubectl run busybox --image=busybox -it --rm -- /bin/sh` | Debug with busybox | Launches temporary debugging pod with shell. |
| `kubectl cp ${POD}:${SRC} ${DEST} -n ${NS}` | Copy from pod | Downloads file from container to local. |
| `kubectl cp ${SRC} ${POD}:${DEST} -n ${NS}` | Copy to pod | Uploads file to container. |
| `kubectl proxy` | Start API proxy | Exposes Kubernetes API on localhost. |
| `kubectl api-resources` | List API resources | Shows all resource types with shortnames. |
| `kubectl explain ${RESOURCE}` | Show resource schema | Displays field documentation for resource type. |
| `kubeadm init` | Initialize control plane | Bootstraps new Kubernetes master node. |
| `kubeadm join ${ENDPOINT} --token ${TOKEN}` | Join node to cluster | Adds worker node to existing cluster. |
| `kubeadm upgrade plan` | Check upgrade path | Shows available cluster version upgrades. |
| `kubeadm upgrade apply ${VERSION}` | Upgrade control plane | Updates master components to new version. |
| `helm list -n ${NS}` | List Helm releases | Shows deployed charts in namespace. |
| `helm install ${RELEASE} ${CHART} -n ${NS}` | Install Helm chart | Deploys chart as release. |
| `helm upgrade ${RELEASE} ${CHART} -n ${NS}` | Upgrade Helm release | Updates release with new chart version. |
| `helm uninstall ${RELEASE} -n ${NS}` | Uninstall Helm release | Removes chart and resources. |
| `ETCDCTL_API=3 etcdctl snapshot save ${FILE}` | Backup etcd [kubeadm] | Creates etcd backup snapshot file. |

## 8. GitLab CI/CD

| Command | Description | Explanation |
|---|---|---|
| `glab auth login` | Authenticate with GitLab | Configures CLI authentication token. |
| `glab repo list` | List repositories | Shows repos user has access to. |
| `glab repo clone ${REPO}` | Clone repository | Downloads GitLab repo to local. |
| `glab issue list` | List project issues | Shows open issues in repo. |
| `glab issue create` | Create new issue | Opens interactive issue creation. |
| `glab mr list` | List merge requests | Shows open MRs in project. |
| `glab mr create` | Create merge request | Opens interactive MR creation. |
| `glab mr view ${ID}` | View merge request | Shows MR details and status. |
| `glab mr merge ${ID}` | Merge request | Merges specified MR. |
| `glab pipeline list` | List pipelines | Shows recent pipelines with status. |
| `glab pipeline status` | Show pipeline status | Displays status of current branch pipeline. |
| `glab pipeline ci view ${ID}` | View pipeline details | Shows jobs and stages for pipeline. |
| `glab ci view` | View CI for branch | Shows CI status for current branch. |
| `glab ci trace ${JOB_ID}` | Show job logs | Displays logs for specific CI job. |
| `curl -X POST --fail -F token=${TOKEN} -F ref=${BRANCH} ${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/trigger/pipeline` | Trigger pipeline via API | Starts pipeline using trigger token. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/pipelines/${ID}"` | Get pipeline via API | Retrieves pipeline details using REST API. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/jobs/${JOB_ID}/artifacts"` | Download job artifacts | Fetches artifacts from completed job. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/jobs/${JOB_ID}/trace"` | Get job log via API | Downloads job execution log via API. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/pipelines/${ID}/cancel" -X POST` | Cancel pipeline | Stops running pipeline via API. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/pipelines/${ID}/retry" -X POST` | Retry pipeline | Restarts failed pipeline via API. |
| `glab ci lint` | Validate CI config | Checks .gitlab-ci.yml syntax and structure. |
| `glab variable list` | List CI/CD variables | Shows project variables. |
| `glab variable set ${KEY} ${VALUE}` | Set CI/CD variable | Creates or updates project variable. |
| `glab variable delete ${KEY}` | Delete CI/CD variable | Removes project variable. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables"` | List variables via API | Gets all project variables via API. |
| `curl --request POST --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/variables" --form "key=${KEY}" --form "value=${VALUE}"` | Create variable via API | Adds new project variable via API. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/runners"` | List runners via API | Shows available CI runners. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/runners"` | List project runners | Shows runners enabled for project. |
| `curl --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches"` | List protected branches | Shows branches with protection rules. |
| `curl --request POST --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches?name=${BRANCH}"` | Protect branch via API | Adds protection to branch via API. |
| `curl --request DELETE --header "PRIVATE-TOKEN: ${TOKEN}" "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/protected_branches/${BRANCH}"` | Unprotect branch [DANGER] | Removes branch protection via API. |
| `glab release list` | List releases | Shows project releases. |
| `glab release create ${TAG}` | Create release | Publishes new release with tag. |

## 9. GitHub Actions

| Command | Description | Explanation |
|---|---|---|
| `gh auth login` | Authenticate with GitHub | Configures GitHub CLI authentication. |
| `gh auth status` | Check auth status | Shows current authentication state and user. |
| `gh workflow list` | List workflows | Shows all workflows in repository. |
| `gh workflow view ${WORKFLOW}` | View workflow details | Displays workflow configuration and recent runs. |
| `gh workflow run ${WORKFLOW}` | Trigger workflow manually | Starts workflow via workflow_dispatch event. |
| `gh workflow enable ${WORKFLOW}` | Enable workflow | Activates disabled workflow. |
| `gh workflow disable ${WORKFLOW}` | Disable workflow | Prevents workflow from running. |
| `gh run list` | List workflow runs | Shows recent runs with status. |
| `gh run list --workflow=${WORKFLOW}` | List runs for workflow | Filters runs by specific workflow. |
| `gh run view ${RUN_ID}` | View run details | Shows jobs and steps for run. |
| `gh run watch ${RUN_ID}` | Watch run live | Monitors run progress in real-time. |
| `gh run rerun ${RUN_ID}` | Rerun workflow | Restarts failed or completed run. |
| `gh run cancel ${RUN_ID}` | Cancel running workflow | Stops in-progress run. |
| `gh run download ${RUN_ID}` | Download run artifacts | Fetches all artifacts from run. |
| `gh run download ${RUN_ID} -n ${ARTIFACT}` | Download specific artifact | Fetches named artifact from run. |
| `gh run view ${RUN_ID} --log` | View run logs | Displays logs for all jobs. |
| `gh run view ${RUN_ID} --log-failed` | View failed job logs | Shows logs only for failed jobs. |
| `gh secret list` | List repository secrets | Shows secret names without values. |
| `gh secret set ${NAME}` | Create repository secret | Adds encrypted secret interactively. |
| `gh secret set ${NAME} < ${FILE}` | Set secret from file | Creates secret from file contents. |
| `gh secret delete ${NAME}` | Delete repository secret | Removes secret from repository. |
| `gh variable list` | List repository variables | Shows variables with values. |
| `gh variable set ${NAME} --body "${VALUE}"` | Set repository variable | Creates or updates variable. |
| `gh variable delete ${NAME}` | Delete repository variable | Removes variable from repository. |
| `gh cache list` | List action caches | Shows cached data with keys. |
| `gh cache delete ${KEY}` | Delete cache entry | Removes specific cache by key. |
| `gh cache delete --all` | Delete all caches [DANGER] | Removes all cached data for repo. |
| `gh release list` | List releases | Shows published releases. |
| `gh release create ${TAG}` | Create release | Publishes new release with assets. |
| `gh release view ${TAG}` | View release details | Shows release notes and assets. |
| `gh release download ${TAG}` | Download release assets | Fetches all assets from release. |
| `gh api repos/${OWNER}/${REPO}/actions/runs` | List runs via API | Gets workflow runs using REST API. |
| `gh api repos/${OWNER}/${REPO}/actions/workflows` | List workflows via API | Gets workflows using REST API. |
| `gh api -X POST repos/${OWNER}/${REPO}/actions/workflows/${ID}/dispatches -f ref=${BRANCH}` | Trigger workflow via API | Dispatches workflow using API. |

## 10. Prometheus

| Command | Description | Explanation |
|---|---|---|
| `promtool check config ${FILE}` | Validate Prometheus config | Checks prometheus.yml syntax and validity. |
| `promtool check rules ${FILE}` | Validate recording/alerting rules | Verifies rule file syntax and correctness. |
| `promtool check metrics` | Validate metrics format | Checks stdin metrics for format issues. |
| `promtool tsdb dump ${DATA_DIR}` | Dump TSDB data | Exports time-series data from storage. |
| `promtool tsdb list ${DATA_DIR}` | List TSDB blocks | Shows storage blocks with time ranges. |
| `promtool tsdb analyze ${DATA_DIR}` | Analyze TSDB storage | Provides statistics on cardinality and storage. |
| `promtool query instant ${SERVER} '${QUERY}'` | Execute instant query | Runs PromQL query at single point in time. |
| `promtool query range ${SERVER} '${QUERY}' --start=${START} --end=${END}` | Execute range query | Runs PromQL query over time range. |
| `curl ${PROMETHEUS_URL}/api/v1/query?query=${QUERY}` | Instant query via API | Executes PromQL instant query via HTTP. |
| `curl '${PROMETHEUS_URL}/api/v1/query_range?query=${QUERY}&start=${START}&end=${END}&step=${STEP}'` | Range query via API | Executes PromQL range query via HTTP. |
| `curl ${PROMETHEUS_URL}/api/v1/targets` | List scrape targets | Shows all configured targets with health status. |
| `curl ${PROMETHEUS_URL}/api/v1/label/__name__/values` | List all metric names | Returns all available metric names. |
| `curl ${PROMETHEUS_URL}/api/v1/series?match[]=${SELECTOR}` | Query series metadata | Lists time series matching selector. |
| `curl -X POST ${PROMETHEUS_URL}/-/reload` | Reload configuration | Hot-reloads prometheus.yml without restart. |
| `curl ${PROMETHEUS_URL}/-/ready` | Check readiness | Returns 200 when Prometheus is ready. |
| `curl ${PROMETHEUS_URL}/-/healthy` | Check health | Returns 200 when Prometheus is healthy. |
| `curl ${PROMETHEUS_URL}/api/v1/status/config` | Get current config | Shows active Prometheus configuration. |
| `curl ${PROMETHEUS_URL}/api/v1/status/flags` | Get runtime flags | Shows command-line flags in effect. |
| `curl ${PROMETHEUS_URL}/api/v1/alertmanagers` | List Alertmanager instances | Shows connected Alertmanager endpoints. |
| `curl ${PROMETHEUS_URL}/api/v1/alerts` | List active alerts | Shows currently firing alerts. |
| `curl ${PROMETHEUS_URL}/api/v1/rules` | List alerting/recording rules | Shows all loaded rule groups. |
| `curl '${PROMETHEUS_URL}/api/v1/query?query=up'` | Query target up status | Checks which targets are up/down. |
| `curl '${PROMETHEUS_URL}/api/v1/query?query=rate(http_requests_total[5m])'` | Query HTTP request rate | Calculates per-second rate over 5 minutes. |
| `curl '${PROMETHEUS_URL}/api/v1/query?query=avg_over_time(cpu_usage[1h])'` | Query average CPU usage | Computes average CPU over 1 hour. |
| `curl '${PROMETHEUS_URL}/api/v1/query?query=sum(rate(requests_total[5m]))by(method)'` | Query requests by method | Aggregates request rate grouped by HTTP method. |
| `promtool test rules ${TEST_FILE}` | Test rule unit tests | Runs unit tests defined for rules. |
| `promtool query labels ${SERVER} __name__` | List metric names | Retrieves all metric names from server. |
| `promtool query labels ${SERVER} ${LABEL}` | List label values | Gets all values for specified label. |
| `curl -X POST ${PROMETHEUS_URL}/api/v1/admin/tsdb/delete_series?match[]=${SELECTOR}` | Delete series [DANGER] | Removes time series matching selector permanently. |
| `curl -X POST ${PROMETHEUS_URL}/api/v1/admin/tsdb/clean_tombstones` | Clean deleted series | Frees disk space from deleted series. |
| `curl -X POST ${PROMETHEUS_URL}/api/v1/admin/tsdb/snapshot` | Create TSDB snapshot | Creates backup snapshot of database. |
