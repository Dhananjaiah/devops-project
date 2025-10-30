# DevOps Interview Q&A

## 1. Linux

| Question | Answer | Explanation |
|---|---|---|
| [Linux][CMD] What does `kill -9 ${PID}` do? | Forcefully terminates process immediately | Sends SIGKILL; no cleanup; last resort only. |
| [Linux][SCENARIO] Server load average 20+ but CPU idle, what's wrong? | Processes waiting on I/O | High iowait; check disk/network bottlenecks with `iostat`. |
| [Linux][GOTCHA] Why does `rm -rf /` fail on modern systems? | Protected by `--no-preserve-root` requirement | Safety flag prevents accidental root deletion. |
| [Linux][CMD] What's the difference between `systemctl start` vs `systemctl enable`? | Start runs now; enable at boot | Start immediate; enable persists across reboots. |
| [Linux][SECURITY] How to find all SUID binaries? | `find / -perm -4000 -type f` | SUID escalates privileges; audit regularly for security. |
| [Linux][SCENARIO] SSH login works but `scp` fails with "Permission denied" | Check home directory permissions | Home must be readable; fix with `chmod 755 ~`. |
| [Linux][GOTCHA] Process killed after SSH disconnect despite `nohup` | Use `nohup` AND redirect output | Must redirect: `nohup cmd > out 2>&1 &`. |
| [Linux][CMD] What does `lsof -i :8080` show? | Process listening on port 8080 | Lists PID, user, process using that port. |
| [Linux][BEST PRACTICE] Preferred method to check listening ports? | Use `ss -tuln` over netstat | Faster, modern, part of iproute2 package. |
| [Linux][SCENARIO] Disk full but `df` shows space available | Check inodes with `df -i` | Exhausted inodes prevent file creation despite space. |
| [Linux][GOTCHA] `chmod 777` on sensitive files risk | World-readable/writable security hole | Use least privilege; 644 files, 755 dirs. |
| [Linux][CMD] What does `journalctl -xe` do? | Show journal end with explanations | Last entries with catalog details for debugging. |
| [Linux][SECURITY] How to enforce password complexity? | Edit `/etc/security/pwquality.conf` | Set minlen, complexity requirements for PAM. |
| [Linux][SCENARIO] System time drifts constantly | Check and fix NTP/chrony service | Use `timedatectl set-ntp true` and verify sync. |
| [Linux][ADV] Trade-off: swap on SSD vs no swap | Swap extends memory but wears SSD | Balance based on workload; monitor write amplification. |
| [Linux][CMD] Difference between `jobs` and `ps`? | Jobs shows shell background; ps all | Jobs for current shell only; ps system-wide. |
| [Linux][GOTCHA] Why does `sudo su` fail in scripts? | Interactive password prompt blocks automation | Use `sudo -i` or configure passwordless sudo. |
| [Linux][SCENARIO] Network interface down after reboot | Check NetworkManager vs systemd-networkd conflict | Disable one manager; single source of truth. |
| [Linux][CMD] What does `strace -p ${PID}` do? | Trace syscalls of running process | Debug hanging process; see actual system calls. |
| [Linux][BEST PRACTICE] How to persist iptables rules across reboots? | Save with `iptables-save > /etc/rules.v4` | Or use `iptables-persistent` package to automate. |
| [Linux][SCENARIO] High memory usage but no big processes | Check kernel buffers and cache | Use `free -m`; cached memory released when needed. |
| [Linux][SECURITY] How to scan for open ports on host? | `nmap localhost` or `ss -tuln` | Internal scan with ss; external with nmap. |
| [Linux][GOTCHA] `usermod -G` removes user from other groups | Use `-aG` to append groups | `-G` replaces; `-aG` appends to existing groups. |
| [Linux][CMD] What does `dmesg | tail` show? | Recent kernel ring buffer messages | Hardware events, driver loads, kernel errors. |
| [Linux][SCENARIO] Cron job runs manually but fails when scheduled | Check PATH and environment variables | Cron minimal PATH; use absolute paths always. |
| [Linux][ADV] When to use `nice` vs `ionice`? | Nice for CPU; ionice for I/O | CPU-bound use nice; disk I/O use ionice. |
| [Linux][BEST PRACTICE] How to safely test firewall rules? | Add timeout: `iptables -A ... && sleep 300` | Auto-rollback prevents lockout if SSH drops. |
| [Linux][SCENARIO] Log rotation not working for app logs | Configure logrotate in `/etc/logrotate.d/` | Create app-specific config with rotation policy. |
| [Linux][SECURITY] How to find files modified in last 24h? | `find /path -mtime -1` | Audit changes; -1 is last 24 hours. |
| [Linux][GOTCHA] Why does `>` truncate file before command runs? | Shell redirects before executing command | Use `tee` or `>>` append to preserve content. |
| [Linux][CMD] What's difference between `/dev/null` and `/dev/zero`? | Null discards; zero provides infinite zeros | Null for output; zero for input/overwrite. |
| [Linux][ADV] RAID 0 vs RAID 1 vs RAID 5 tradeoffs | Speed vs redundancy vs capacity | RAID 0 fast/no safety; 1 mirrored; 5 balanced. |
| [Linux][SCENARIO] Server responds to ping but SSH times out | Check sshd status and firewall rules | `systemctl status sshd`; verify port 22 open. |
| [Linux][BEST PRACTICE] How to check disk I/O bottlenecks? | Use `iostat -x 1` for extended stats | Watch await, svctm, %util metrics continuously. |

## 2. Bash

| Question | Answer | Explanation |
|---|---|---|
| [Bash][CMD] What does `set -euxo pipefail` do? | Exit on error, undefined var, pipe failure | Best practice for safe scripts; enables debugging. |
| [Bash][GOTCHA] Why does `var=value` (space) fail? | Space makes it command, not assignment | No spaces around `=` in assignments. |
| [Bash][SCENARIO] Script works in terminal but fails in cron | Missing PATH or environment variables | Cron has minimal env; use absolute paths. |
| [Bash][CMD] What's difference between `$@` and `$*`? | `$@` expands to separate words; `$*` single | Quoted `"$@"` preserves arguments; prefer it. |
| [Bash][SECURITY] How to read passwords without echo? | `read -s PASSWORD` | Silent input prevents shoulder surfing and logs. |
| [Bash][GOTCHA] Why does `[ $var == "value" ]` fail if var empty? | Unquoted var expands to nothing | Always quote: `[ "$var" == "value" ]`. |
| [Bash][CMD] What does `trap 'cleanup' EXIT` do? | Run cleanup function on script exit | Ensures cleanup even on error or interrupt. |
| [Bash][BEST PRACTICE] How to iterate over array in bash? | `for item in "${array[@]}"; do` | Use `"${array[@]}"` to preserve spaces in elements. |
| [Bash][SCENARIO] Command substitution `$(...)` returns error code 0 despite failure | Check `$?` immediately after substitution | Capture in var: `result=$(cmd)` then check `$?`. |
| [Bash][GOTCHA] Single vs double quotes in variable expansion | Single prevents expansion; double allows | Use double `"$var"` for expansion always. |
| [Bash][CMD] What does `${var:-default}` do? | Use default if var unset/empty | Parameter expansion with fallback value provided. |
| [Bash][SECURITY] How to avoid command injection in scripts? | Quote all variables; validate input | Use `"$var"` and sanitize user inputs. |
| [Bash][SCENARIO] Script hangs reading stdin but expects pipe | Check if stdin is terminal or pipe | Use `[ -t 0 ]` to test terminal. |
| [Bash][ADV] When to use `[[ ]]` vs `[ ]`? | `[[ ]]` bash-specific, more features, safer | `[[ ]]` supports regex, `&&`, no word splitting. |
| [Bash][CMD] What does `exec 3< file` do? | Opens file descriptor 3 for reading | Custom FD for parallel I/O operations. |
| [Bash][GOTCHA] Why does piping lose variable assignments? | Pipe runs subshell; changes don't persist | Use process substitution or while read loop. |
| [Bash][BEST PRACTICE] How to parse JSON in bash? | Use `jq` for JSON parsing | Reliable, safe; avoid regex on JSON. |
| [Bash][CMD] What's difference between `source` and `./script`? | Source runs in current shell; `.` new | Source for env vars; execute for isolation. |
| [Bash][SCENARIO] Large file processing causes memory issues | Process line-by-line with `while read` | Streams instead of loading entire file. |
| [Bash][SECURITY] How to create secure temp files? | `mktemp` with random names | Prevents race conditions and overwrites. |
| [Bash][GOTCHA] Background job `&` output intermixes with terminal | Redirect stdout/stderr for each background job | `cmd > out.log 2>&1 &` for clean output. |
| [Bash][CMD] What does `${var%%pattern}` do? | Remove longest match from end | Greedy suffix removal; `%` is shortest. |
| [Bash][ADV] Bash subshell `()` vs code block `{}`? | Subshell isolated; block runs in current | Subshell for isolation; block for performance. |
| [Bash][BEST PRACTICE] How to check if command exists? | `command -v cmd > /dev/null` | Portable across shells; use before calling. |
| [Bash][SCENARIO] Bash script exits early without error message | Set `set -e` to catch unhandled errors | Forces exit on any command failure. |
| [Bash][CMD] What does `declare -r VAR=value` do? | Creates read-only variable | Prevents modification; immutable constant declaration. |
| [Bash][GOTCHA] Why does `cd $(dirname $0)` fail in symlinks? | `$0` shows symlink, not actual path | Use `readlink -f $0` to resolve true path. |
| [Bash][SECURITY] How to sanitize filenames for shell use? | Remove special chars or use `printf %q` | Prevents command injection via filenames. |
| [Bash][CMD] What does `${#array[@]}` return? | Array length (number of elements) | Count elements; `${#var}` for string length. |
| [Bash][BEST PRACTICE] How to handle errors in pipelines? | Use `set -o pipefail` | Default hides errors; pipefail exposes them. |

## 3. Git & GitHub

| Question | Answer | Explanation |
|---|---|---|
| [Git][CMD] What does `git reset --hard HEAD~1` do? | Discards last commit and working changes | Moves HEAD back one; unrecoverable data loss. |
| [Git][SCENARIO] Pushed sensitive data to GitHub accidentally | Rotate secrets; use `git filter-branch` or BFG | Rewrite history; force push; assume leaked already. |
| [Git][GOTCHA] Why does `git pull` create merge commits? | Default merges remote into local | Use `git pull --rebase` for linear history. |
| [Git][CMD] Difference between `git rebase` vs `git merge`? | Rebase rewrites; merge preserves history | Rebase linear; merge shows branch points. |
| [Git][BEST PRACTICE] How to write good commit messages? | Imperative mood, 50 char subject, body explains | "Fix bug" not "Fixed"; explain why. |
| [Git][SCENARIO] Need to fix bug in old commit without rewriting history | Create new commit with fix | Never rewrite public history; append fixes. |
| [Git][SECURITY] How to sign commits with GPG? | `git config commit.gpgsign true` | Proves author identity; required for critical repos. |
| [Git][GOTCHA] Why does `git checkout` discard uncommitted changes? | Checkout overwrites working directory | Use `git stash` first to save work. |
| [Git][CMD] What does `git stash pop` vs `git stash apply` do? | Pop applies and removes; apply keeps | Pop once; apply when reusing multiple times. |
| [Git][SCENARIO] Need to find commit that introduced bug | Use `git bisect` binary search | Automated binary search through commit history. |
| [Git][ADV] When to use `git rebase -i` for cleanup? | Clean up local commits before pushing | Squash, reorder, edit; never on pushed commits. |
| [Git][CMD] What does `git reflog` show? | History of HEAD movements | Recover lost commits; lasts 90 days default. |
| [Git][BEST PRACTICE] How to protect main branch from direct pushes? | Enable protected branch rules in GitHub | Require PRs, reviews, status checks. |
| [Git][GOTCHA] Why does `git clone` without `--depth` take forever? | Downloads entire history, all branches | Use `--depth 1` for CI/CD shallow clones. |
| [Git][SCENARIO] Accidentally committed to wrong branch | Use `git cherry-pick` to copy commit | Cherry-pick to correct branch; reset original. |
| [Git][SECURITY] How to prevent force push on shared branches? | Configure server hooks or branch protection | Block force push except admins; preserve history. |
| [Git][CMD] What does `git blame -w -C` do? | Show authorship ignoring whitespace and moves | Traces code origin across file moves. |
| [Git][GOTCHA] Why does rebase conflict resolution repeat for each commit? | Each commit replayed independently | Resolve once per conflicting commit in sequence. |
| [Git][SCENARIO] Need to undo `git push --force` | Check reflog; coordinate with team immediately | Restore from reflog if local copy exists. |
| [Git][ADV] Git LFS vs submodules for large files? | LFS for large files; submodules for repos | LFS stores blobs externally; submodules link repos. |
| [Git][CMD] What does `gh pr create --fill` do? | Create PR using commit message | Uses last commit for title/body via CLI. |
| [Git][BEST PRACTICE] How often to commit during development? | Commit small logical units frequently | Atomic commits; easier to review and revert. |
| [Git][SCENARIO] Multiple people editing same file causes conflicts | Communicate; pull before push; small frequent commits | Reduce overlap; rebase to latest before push. |
| [Git][SECURITY] How to audit repository for secrets? | Use `git-secrets` or `truffleHog` scanners | Scan history for credentials, keys, tokens. |
| [Git][GOTCHA] Why does `.gitignore` not ignore tracked files? | Gitignore only affects untracked files | Must `git rm --cached` to stop tracking. |
| [Git][CMD] What does `git clean -fdx` do? | Remove all untracked files and directories | Includes ignored files; cannot be undone. |
| [Git][SCENARIO] Need to split large commit into smaller ones | Use `git reset --soft` then commit parts | Uncommit; stage and commit in logical chunks. |
| [Git][ADV] Merge strategies: fast-forward vs recursive vs ours | Fast-forward linear; recursive default; ours takes ours | Choose based on history preservation needs. |
| [Git][CMD] What does `git tag -a v1.0 -m "Release"` do? | Create annotated tag with message | Annotated preferred; includes tagger metadata. |
| [Git][BEST PRACTICE] How to handle merge vs rebase on feature branches? | Rebase locally; merge to main | Keep feature linear; preserve merge context. |

## 4. AWS (CLI)

| Question | Answer | Explanation |
|---|---|---|
| [AWS][CMD] What does `aws sts assume-role` do? | Temporarily assume different IAM role | Returns temp credentials for cross-account or elevated access. |
| [AWS][SCENARIO] S3 `403 Forbidden` despite correct bucket policy | Check IAM policy and bucket ACLs | Both IAM and bucket policy must allow. |
| [AWS][SECURITY] How to rotate AWS access keys safely? | Create new, update apps, test, delete old | Never delete before confirming new key works. |
| [AWS][GOTCHA] Why does `aws s3 sync` miss updated files? | Compares size and timestamp, not content | Use `--exact-timestamps` or `--size-only` flags. |
| [AWS][COST] How to find unused EBS volumes? | `aws ec2 describe-volumes --filters Name=status,Values=available` | Unattached volumes still incur charges monthly. |
| [AWS][CMD] Difference between `aws s3 cp` vs `aws s3 sync`? | Cp copies once; sync mirrors with updates | Sync only changed files; more efficient. |
| [AWS][SCENARIO] EC2 instance unreachable after security group change | Check both security group and NACLs | Security groups stateful; NACLs stateless, both matter. |
| [AWS][SECURITY] How to enforce MFA for AWS console? | IAM policy with `aws:MultiFactorAuthPresent` condition | Deny actions unless MFA present in request. |
| [AWS][GOTCHA] Why does deleting S3 bucket fail? | Bucket must be empty first | Delete all objects and versions before bucket. |
| [AWS][CMD] What does `aws eks update-kubeconfig` do? | Add EKS cluster to kubectl config | Configures kubectl to authenticate with EKS cluster. |
| [AWS][COST] How to reduce CloudWatch Logs costs? | Set retention policies and filter ingestion | Default infinite retention; set 7-30 days. |
| [AWS][SCENARIO] Lambda timeout errors at 3 seconds | Increase timeout in function configuration | Default 3s; max 15 min; optimize code. |
| [AWS][SECURITY] How to encrypt S3 bucket at rest? | Enable default encryption with KMS or SSE-S3 | SSE-S3 free; KMS more control, auditable. |
| [AWS][ADV] When to use EC2 vs ECS vs EKS? | EC2 VMs; ECS AWS-native containers; EKS Kubernetes | Complexity and control tradeoff; EKS most portable. |
| [AWS][GOTCHA] Why does `aws` CLI hang or timeout? | Check credentials, region, network, endpoint | Verify `~/.aws/config` and `AWS_REGION` set. |
| [AWS][CMD] What does `aws cloudwatch get-metric-statistics` do? | Retrieve metrics data for specified period | Query CloudWatch metrics programmatically for analysis. |
| [AWS][SCENARIO] RDS connection limit reached | Increase max connections parameter or use pooling | Default depends on instance class; RDS proxies help. |
| [AWS][SECURITY] How to scan EC2 instances for vulnerabilities? | Use AWS Inspector or third-party scanners | Automated security assessments for CVEs and compliance. |
| [AWS][COST] How to identify most expensive AWS resources? | Use Cost Explorer with grouping by service | Tag resources for granular cost allocation. |
| [AWS][GOTCHA] Why does IAM policy change not take effect? | IAM eventual consistency delay | Wait 10-30 seconds; also check policy syntax. |
| [AWS][CMD] What does `aws ecr get-login-password` do? | Get Docker login password for ECR | Pipe to `docker login` for registry authentication. |
| [AWS][SCENARIO] KMS key deletion prevents decrypting old data | Use 7-30 day waiting period to recover | Schedule deletion; cancel if needed before expiry. |
| [AWS][BEST PRACTICE] How to handle AWS credentials in CI/CD? | Use IAM roles for EC2/ECS or OIDC | Never hardcode keys; use temporary credentials. |
| [AWS][SECURITY] How to enable CloudTrail for audit logging? | Create trail logging all regions to S3 | Captures all API calls for compliance. |
| [AWS][ADV] S3 Transfer Acceleration vs CloudFront for downloads? | Acceleration for uploads; CloudFront for downloads | Acceleration optimizes PUT; CloudFront caches globally. |
| [AWS][CMD] What does `aws autoscaling describe-auto-scaling-groups` do? | List ASG configurations and current state | Shows desired, min, max capacity and instances. |
| [AWS][SCENARIO] EBS volume full, instance unresponsive | Create snapshot, increase size, replace volume | Snapshot first for safety; extend filesystem after. |
| [AWS][GOTCHA] Why does tagging resources fail in some regions? | Resource type not available in region | Check service availability per region documentation. |
| [AWS][COST] How to stop EC2 instance without losing data? | Stop instance; EBS persists, instance-store lost | Stopped instances only pay EBS storage. |
| [AWS][SECURITY] How to enable VPC Flow Logs? | Create flow log to CloudWatch or S3 | Captures IP traffic for network monitoring. |

## 5. Terraform

| Question | Answer | Explanation |
|---|---|---|
| [Terraform][CMD] What does `terraform plan` do? | Shows changes before applying | Dry run; previews create, update, delete operations. |
| [Terraform][SCENARIO] State file out of sync with actual infrastructure | Run `terraform refresh` then `terraform plan` | Refresh updates state from real world. |
| [Terraform][GOTCHA] Why does destroying resource fail with dependencies? | Dependency still references it | Remove dependent resources first or use `-target`. |
| [Terraform][SECURITY] How to protect state file containing secrets? | Use remote backend with encryption enabled | S3 with encryption, DynamoDB locking, restrict access. |
| [Terraform][CMD] Difference between `terraform apply` and `terraform apply -auto-approve`? | Auto-approve skips confirmation prompt | Use in CI/CD; dangerous for manual runs. |
| [Terraform][BEST PRACTICE] How to handle multiple environments? | Use workspaces or separate state files | Workspaces simple; separate states more isolated. |
| [Terraform][SCENARIO] Resource exists but Terraform wants to recreate it | Import existing resource into state | `terraform import` to adopt existing resources. |
| [Terraform][GOTCHA] Why does Terraform create new resource instead of updating? | Argument forces replacement in plan | Some changes require recreate; check plan carefully. |
| [Terraform][CMD] What does `terraform taint` do? | Mark resource for recreation on next apply | Forces destroy and recreate of specific resource. |
| [Terraform][ADV] When to use `count` vs `for_each`? | Count for identical; for_each for unique | For_each preserves identity with map keys. |
| [Terraform][SECURITY] How to manage secrets in Terraform? | Use variables, environment vars, or vaults | Never commit secrets; use secret managers. |
| [Terraform][SCENARIO] State lock prevents running Terraform | Force unlock with caution after confirming safe | `terraform force-unlock ${LOCK_ID}` if process died. |
| [Terraform][BEST PRACTICE] How to version Terraform configurations? | Pin provider and module versions | Prevents breaking changes; use `required_version`. |
| [Terraform][GOTCHA] Why does module output not update? | Must run apply in module parent | Module changes require parent apply propagation. |
| [Terraform][CMD] What does `terraform state mv` do? | Rename resource in state file | Reorganize without destroying; changes reference only. |
| [Terraform][SCENARIO] Drift detected between Terraform and cloud | Review drift; update code or apply to reconcile | Use `terraform plan` to see differences. |
| [Terraform][SECURITY] How to implement least privilege for Terraform? | Separate roles for plan and apply | Plan read-only; apply with write permissions. |
| [Terraform][ADV] Local vs remote backend tradeoffs? | Local simple; remote enables team collaboration | Remote adds locking, versioning, security. |
| [Terraform][GOTCHA] Why does provider plugin download fail? | Check network, registry access, version constraints | Verify `.terraform.lock.hcl` and plugin cache. |
| [Terraform][CMD] What does `terraform graph` do? | Generate visual dependency graph | Outputs DOT format; visualize with Graphviz. |
| [Terraform][BEST PRACTICE] How to handle Terraform state backups? | Enable versioning on S3 backend | Automatic backups prevent accidental corruption. |
| [Terraform][SCENARIO] Need to replace single resource without affecting others | Use `-target` flag with apply | Limits scope; use carefully, check dependencies. |
| [Terraform][COST] How to estimate cost before applying? | Use `terraform plan` with cost estimation tools | Infracost or cloud provider calculators. |
| [Terraform][GOTCHA] Why does `terraform destroy` hang? | Dependency issues or API rate limits | Check logs; may need `-parallelism=1` flag. |
| [Terraform][CMD] What does `terraform validate` do? | Check syntax and logic errors | Validates without accessing state or providers. |
| [Terraform][SECURITY] How to prevent accidental state deletion? | Enable MFA delete on S3 bucket | Adds protection layer for state file. |
| [Terraform][SCENARIO] Terraform version mismatch between team members | Use `.terraform-version` file with `tfenv` | Ensures consistent version across team and CI. |
| [Terraform][ADV] Data source vs resource block difference? | Data reads existing; resource creates/manages | Data for reference; resource for management. |
| [Terraform][BEST PRACTICE] How to organize large Terraform projects? | Separate by environment and layer | Network, compute, data layers in modules. |
| [Terraform][GOTCHA] Why does variable default not work? | Variable set elsewhere with higher precedence | Check env vars, tfvars files, CLI flags. |

## 6. Ansible

| Question | Answer | Explanation |
|---|---|---|
| [Ansible][CMD] What does `ansible all -m ping` do? | Test connectivity to all inventory hosts | Verifies SSH and Python availability on targets. |
| [Ansible][SCENARIO] Playbook fails with "Host key verification failed" | Disable host key checking or add to known_hosts | Set `host_key_checking = False` in config. |
| [Ansible][GOTCHA] Why does `become: yes` still show permission errors? | User lacks sudo permissions or password needed | Configure passwordless sudo or use `--ask-become-pass`. |
| [Ansible][SECURITY] How to encrypt sensitive data in Ansible? | Use `ansible-vault encrypt` on files | Protects passwords, keys in version control. |
| [Ansible][CMD] Difference between ad-hoc command and playbook? | Ad-hoc single task; playbook orchestrates multiple | Ad-hoc quick; playbook complex, reusable workflows. |
| [Ansible][BEST PRACTICE] How to ensure task idempotency? | Use modules that check before changing | Commands not idempotent; use file, package modules. |
| [Ansible][SCENARIO] Play runs on wrong hosts despite limit flag | Check inventory groups and host patterns | Verify `--limit` syntax and inventory structure. |
| [Ansible][GOTCHA] Why does variable precedence cause unexpected values? | 22 precedence levels; extra-vars highest | Use `-e` for overrides; check precedence docs. |
| [Ansible][CMD] What does `ansible-playbook --check` do? | Dry run without making changes | Shows what would change; not all modules support. |
| [Ansible][SECURITY] How to use Ansible with jump/bastion hosts? | Configure `ProxyCommand` in ssh_config | Set `ansible_ssh_common_args` for proxy jump. |
| [Ansible][SCENARIO] Task hangs waiting for user input | Redirect stdin or use non-interactive flags | Pass `-y` to commands or use `stdin` parameter. |
| [Ansible][ADV] When to use `include_tasks` vs `import_tasks`? | Include dynamic runtime; import static parse-time | Include for conditionals; import for performance. |
| [Ansible][BEST PRACTICE] How to structure Ansible roles? | Use standard directory layout with defaults, tasks | Roles for reusability; follow best practices structure. |
| [Ansible][GOTCHA] Why does `register` variable not persist across plays? | Variables scoped to play unless set_fact | Use `set_fact` for cross-play persistence. |
| [Ansible][CMD] What does `ansible-galaxy install` do? | Download roles from Ansible Galaxy | Installs community roles to local system. |
| [Ansible][SCENARIO] Need to run tasks on localhost control node | Set `hosts: localhost` and `connection: local` | Runs locally without SSH overhead. |
| [Ansible][SECURITY] How to rotate vault password safely? | Use `ansible-vault rekey` command | Changes encryption key without manual decrypt/encrypt. |
| [Ansible][GOTCHA] Why does `with_items` loop skip on empty list? | Empty list means zero iterations | Check list population; use `when` conditions. |
| [Ansible][CMD] What does `ansible-playbook --tags deploy` do? | Run only tasks tagged 'deploy' | Selective execution; speeds up targeted runs. |
| [Ansible][BEST PRACTICE] How to test Ansible roles locally? | Use Molecule for testing framework | Automates role testing across scenarios. |
| [Ansible][SCENARIO] Playbook slow with many hosts | Increase `forks` in ansible.cfg | Default 5; increase based on control capacity. |
| [Ansible][ADV] Strategy: linear vs free vs debug? | Linear waits per task; free parallel; debug interactive | Free faster; linear predictable; debug troubleshooting. |
| [Ansible][SECURITY] How to prevent playbook from running in production accidentally? | Use `--limit` and confirmation prompts | Add `pause` task before destructive operations. |
| [Ansible][GOTCHA] Why does `changed_when` not prevent handler notification? | Handlers notified unless `changed_when: false` explicitly | Set `changed_when: false` to skip handlers. |
| [Ansible][CMD] What does `ansible-doc -l` do? | List all available modules | Browse module documentation offline. |
| [Ansible][SCENARIO] Need to run different tasks based on OS | Use `ansible_facts['os_family']` in conditionals | Gather facts automatically; use in `when` clauses. |
| [Ansible][BEST PRACTICE] How to handle Ansible dependencies? | Use `requirements.yml` for roles and collections | Pin versions; install with `ansible-galaxy install -r`. |
| [Ansible][GOTCHA] Why does delegation fail with variables? | Variables from inventory, not delegated host | Use `hostvars[inventory_hostname]` to access original. |
| [Ansible][CMD] What does `ansible-inventory --graph` do? | Display inventory hierarchy as tree | Visualizes groups and host relationships. |
| [Ansible][SECURITY] How to limit playbook to specific sudo commands? | Configure sudoers with command restrictions | Add commands to `/etc/sudoers` per user. |

## 7. Kubernetes

| Question | Answer | Explanation |
|---|---|---|
| [K8s][CMD] What does `kubectl get pods -A` do? | List all pods across all namespaces | `-A` shorthand for `--all-namespaces`; cluster-wide view. |
| [K8s][SCENARIO] Pod Pending with "Insufficient cpu" | Increase resource limits or scale nodes | Scheduler can't place pod; adjust requests or capacity. |
| [K8s][GOTCHA] Why does pod restart loop crash? | Check logs with `kubectl logs ${POD} --previous` | Previous container logs reveal crash cause. |
| [K8s][SECURITY] How to enforce pod security policies? | Use Pod Security Admission controller | Replaces PSP; enforces security standards at namespace. |
| [K8s][CMD] Difference between Deployment and StatefulSet? | Deployment stateless; StatefulSet ordered, persistent | StatefulSet for databases; Deployment for apps. |
| [K8s][SCENARIO] Service not routing traffic to pods | Check pod labels match service selector | Label mismatch breaks service endpoint discovery. |
| [K8s][GOTCHA] Why does ConfigMap update not affect running pods? | Pods must restart to pick up changes | Or use volume mounts with eventual consistency. |
| [K8s][BEST PRACTICE] How to implement zero-downtime deployments? | Use rolling update with readiness probes | Probes prevent traffic to unready pods. |
| [K8s][CMD] What does `kubectl exec -it ${POD} -- /bin/sh` do? | Interactive shell into running pod | Debug inside container; `-it` for terminal. |
| [K8s][SECURITY] How to implement network policies? | Define NetworkPolicy resources for traffic control | Default all traffic allowed; policies restrict. |
| [K8s][SCENARIO] Pod evicted due to disk pressure | Check node disk usage; clean images/logs | Kubelet evicts when disk threshold exceeded. |
| [K8s][ADV] When to use HPA vs VPA? | HPA scales replicas; VPA adjusts resources | HPA for load; VPA for right-sizing. |
| [K8s][GOTCHA] Why does service ClusterIP not work outside cluster? | ClusterIP internal only; use NodePort or LoadBalancer | Internal DNS only resolves inside cluster. |
| [K8s][CMD] What does `kubectl rollout restart deployment/${NAME}` do? | Triggers rolling restart of pods | Recreates pods; applies ConfigMap/Secret changes. |
| [K8s][SCENARIO] Ingress returns 503 Service Unavailable | Check backend service and pod health | Verify service endpoints exist and are healthy. |
| [K8s][SECURITY] How to rotate secrets without downtime? | Update secret; rolling restart deployment | Or use external secret managers with sync. |
| [K8s][BEST PRACTICE] How to set resource requests and limits? | Requests for scheduling; limits prevent overuse | Set both; request = typical, limit = max. |
| [K8s][GOTCHA] Why does pod scheduling ignore node selector? | Node missing required labels | Verify node labels with `kubectl get nodes --show-labels`. |
| [K8s][CMD] What does `kubectl describe pod ${POD}` show? | Detailed pod info including events | Events crucial for debugging scheduling, pulling issues. |
| [K8s][SCENARIO] PersistentVolumeClaim stuck in Pending | Check StorageClass and PV availability | Verify provisioner working; check PVC spec. |
| [K8s][ADV] DaemonSet vs Deployment use cases? | DaemonSet one per node; Deployment replicas | DaemonSet for node agents; Deployment for apps. |
| [K8s][SECURITY] How to implement RBAC for users? | Create Role/ClusterRole and bind to subjects | Least privilege; namespace or cluster scope. |
| [K8s][GOTCHA] Why does liveness probe kill healthy pod? | Probe too aggressive or app slow to start | Increase `initialDelaySeconds` and `periodSeconds`. |
| [K8s][CMD] What does `kubectl top nodes` do? | Show resource usage per node | Requires metrics-server; displays CPU and memory. |
| [K8s][SCENARIO] DNS resolution fails inside pods | Check CoreDNS pods status and service | Verify `kube-dns` service and CoreDNS deployment. |
| [K8s][BEST PRACTICE] How to handle database migrations in K8s? | Use init containers or Jobs | Init containers run before app; Jobs one-off. |
| [K8s][SECURITY] How to scan images for vulnerabilities? | Use admission webhooks with scanning tools | Integrate Trivy, Clair; block vulnerable images. |
| [K8s][GOTCHA] Why does horizontal scaling not trigger? | Check HPA metrics source and targets | Verify metrics-server; check target utilization. |
| [K8s][CMD] What does `kubectl drain ${NODE}` do? | Evict pods and mark node unschedulable | Safe node maintenance; cordons then evicts. |
| [K8s][SCENARIO] Node NotReady after network outage | Check kubelet status and CNI plugin | `systemctl status kubelet`; verify pod network. |
| [K8s][ADV] When to use Jobs vs CronJobs? | Jobs one-time; CronJobs scheduled recurring | Jobs for migrations; CronJobs for backups. |
| [K8s][BEST PRACTICE] How to backup etcd cluster? | Use `etcdctl snapshot save` command | Regular backups critical for disaster recovery. |
| [K8s][SECURITY] How to enforce image pull policies? | Set `imagePullPolicy: Always` or use admission | Always validates latest; IfNotPresent caches locally. |
| [K8s][GOTCHA] Why does pod use old image after update? | Image tag `latest` cached locally | Use specific tags; force pull with Always. |
| [K8s][CMD] What does `kubectl apply -f` vs `kubectl create -f` do? | Apply declarative; create imperative | Apply updates; create fails if exists. |
| [K8s][SCENARIO] Cluster upgrade fails halfway through | Check upgrade path and component versions | Follow version skew policy; upgrade incrementally. |
| [K8s][COST] How to identify overprovisioned resources? | Use VPA or metrics analysis tools | Compare requests vs actual usage patterns. |
| [K8s][SECURITY] How to restrict pod capabilities? | Set `securityContext` with dropped capabilities | Drop ALL; add only needed ones. |
| [K8s][GOTCHA] Why does pod toleration not work? | Taint and toleration must exactly match | Check key, value, effect match perfectly. |
| [K8s][CMD] What does `kubectl get events --sort-by='.lastTimestamp'` do? | Show events chronologically | Debug by timeline; recent events first. |
| [K8s][SCENARIO] High memory usage on node without big pods | Check system pods and node processes | Include `kube-system` namespace in investigation. |
| [K8s][BEST PRACTICE] How to implement pod disruption budgets? | Create PDB defining minimum available pods | Protects availability during voluntary disruptions. |

## 8. GitLab CI/CD

| Question | Answer | Explanation |
|---|---|---|
| [GitLab][CMD] What does `only: [master]` in job do? | Restricts job to master branch only | Branch filtering; use `rules` for modern syntax. |
| [GitLab][SCENARIO] Pipeline stuck in "pending" status | Check runner availability and tags | No matching runners; verify runner registration. |
| [GitLab][GOTCHA] Why do job variables not pass to downstream? | Must explicitly pass with `variables` keyword | Variables scoped to job unless propagated. |
| [GitLab][SECURITY] How to protect CI/CD variables? | Mark as protected and masked | Protected for branches/tags; masked hides in logs. |
| [GitLab][CMD] Difference between `artifacts` and `cache`? | Artifacts for outputs; cache for dependencies | Artifacts passed between stages; cache speeds builds. |
| [GitLab][BEST PRACTICE] How to avoid rebuilding unchanged dependencies? | Use cache with appropriate keys | Key by lock file hash for optimal caching. |
| [GitLab][SCENARIO] Job fails with "Could not resolve host" | Check runner network and DNS configuration | Verify runner can reach external registries/repos. |
| [GitLab][GOTCHA] Why does `needs` create unexpected dependencies? | Needs bypasses stage ordering | Creates DAG; jobs run out of stage order. |
| [GitLab][CMD] What does `when: manual` do? | Requires manual trigger to run job | Gates deployments; prevents auto-execution. |
| [GitLab][SECURITY] How to approve deployments to production? | Use protected environments with approvers | Requires manual approval from authorized users. |
| [GitLab][SCENARIO] Pipeline triggers not working from other projects | Check token permissions and branch filters | Verify trigger token and pipeline conditions. |
| [GitLab][ADV] When to use parent-child vs multi-project pipelines? | Parent-child same repo; multi-project cross-repo | Parent-child for monorepos; multi-project for microservices. |
| [GitLab][BEST PRACTICE] How to organize complex pipelines? | Use include and extends for DRY | Template jobs; include from separate files. |
| [GitLab][GOTCHA] Why does cache not work as expected? | Check runner executor and cache location | Docker executor needs volume; cache key matters. |
| [GitLab][CMD] What does `retry: 2` do? | Retries failed job up to 2 times | Handles transient failures automatically. |
| [GitLab][SCENARIO] Need to run job only on schedule | Use `rules` with `$CI_PIPELINE_SOURCE == "schedule"` | Filters by pipeline trigger source. |
| [GitLab][SECURITY] How to scan for secrets in CI pipeline? | Use secret detection analyzer in SAST | Detects hardcoded credentials before merge. |
| [GitLab][GOTCHA] Why does merge train fail unexpectedly? | Check for flaky tests or race conditions | Serial execution; failures block queue. |
| [GitLab][CMD] What does `dependencies: []` do? | Prevents downloading any artifacts | Speeds up job; omit when artifacts unnecessary. |
| [GitLab][BEST PRACTICE] How to version pipeline configuration? | Use pipeline versioning or includes from tags | Pin to stable versions of templates. |
| [GitLab][SCENARIO] Runner out of disk space from builds | Clean up artifacts and configure retention | Set artifact expiration; clean docker images. |
| [GitLab][SECURITY] How to enforce pipeline must pass before merge? | Enable "Pipelines must succeed" in project settings | Prevents merging on failures or skips. |
| [GitLab][GOTCHA] Why does coverage parsing not work? | Regex pattern doesn't match tool output | Verify regex with actual coverage output format. |
| [GitLab][CMD] What does `interruptible: true` do? | Allows canceling job when new commit pushed | Saves resources on outdated pipeline runs. |
| [GitLab][SCENARIO] Deployment job fails with authentication error | Check CI/CD variables and deploy keys | Verify credentials available to job environment. |
| [GitLab][ADV] Directed Acyclic Graph (DAG) vs stages? | DAG parallel execution; stages sequential | DAG faster; stages simpler, predictable order. |
| [GitLab][BEST PRACTICE] How to test pipeline changes safely? | Use merge request pipelines | Test changes before merging to main branch. |
| [GitLab][SECURITY] How to implement compliance pipelines? | Use compliance framework templates | Enforces security scans and policies. |
| [GitLab][GOTCHA] Why does job timeout after 1 hour? | Default job timeout limit exceeded | Increase `timeout` in job or project settings. |
| [GitLab][CMD] What does `resource_group` do? | Ensures only one job runs at a time | Prevents concurrent deployments to same environment. |

## 9. GitHub Actions

| Question | Answer | Explanation |
|---|---|---|
| [GitHub Actions][CMD] What does `workflow_dispatch` trigger do? | Allows manual workflow runs | Adds "Run workflow" button in Actions tab. |
| [GitHub Actions][SCENARIO] Workflow fails with "Resource not accessible by integration" | Check token permissions in workflow | Update `permissions` block for required scopes. |
| [GitHub Actions][GOTCHA] Why does `secrets` not work in forked PRs? | Secrets not available to fork PRs for security | Use `pull_request_target` carefully or skip secrets. |
| [GitHub Actions][SECURITY] How to use OIDC with cloud providers? | Configure `id-token: write` permission | Exchanges GitHub token for cloud credentials. |
| [GitHub Actions][CMD] Difference between `needs` and `if` conditions? | Needs defines dependencies; if adds conditions | Needs runs after; if decides whether run. |
| [GitHub Actions][BEST PRACTICE] How to cache dependencies in workflow? | Use `actions/cache` with appropriate keys | Key by lock file hash for accuracy. |
| [GitHub Actions][SCENARIO] Job fails with rate limit errors | Use `GITHUB_TOKEN` or authenticated requests | Unauthenticated limited to 60 requests per hour. |
| [GitHub Actions][GOTCHA] Why does job skip despite no conditions? | Previous required job failed or was skipped | Check dependencies; use `if: always()` to override. |
| [GitHub Actions][CMD] What does `concurrency` group do? | Limits concurrent runs of workflow | Cancels in-progress runs with `cancel-in-progress: true`. |
| [GitHub Actions][SECURITY] How to restrict workflow to protected branches? | Use `on.push.branches` with protection rules | Combine with environment protection rules. |
| [GitHub Actions][SCENARIO] Self-hosted runner offline unexpectedly | Check runner service and connectivity | Verify service status and GitHub API access. |
| [GitHub Actions][ADV] When to use matrix vs multiple workflows? | Matrix for variations; multiple for independence | Matrix for testing combinations; workflows for separation. |
| [GitHub Actions][BEST PRACTICE] How to share data between jobs? | Upload/download artifacts between jobs | Use `actions/upload-artifact` and `actions/download-artifact`. |
| [GitHub Actions][GOTCHA] Why does environment variable not pass to next step? | Must export or set via `GITHUB_ENV` | Use `echo "VAR=value" >> $GITHUB_ENV`. |
| [GitHub Actions][CMD] What does `pull_request_target` vs `pull_request` do? | Target uses base context; pull_request uses head | Target for write access; careful with untrusted code. |
| [GitHub Actions][SCENARIO] Workflow slow due to setup time | Use Docker containers or custom runners | Pre-built images faster than installing each time. |
| [GitHub Actions][SECURITY] How to audit workflow runs? | Use audit log and workflow run logs | Track who triggered, what changed, results. |
| [GitHub Actions][GOTCHA] Why does checkout action not get tags? | Default shallow clone skips tags | Use `fetch-depth: 0` to get full history. |
| [GitHub Actions][CMD] What does `repository_dispatch` do? | Triggers workflow via API call | External systems trigger workflows programmatically. |
| [GitHub Actions][BEST PRACTICE] How to test workflow changes locally? | Use `act` tool for local testing | Runs workflows in Docker; not 100% compatible. |
| [GitHub Actions][SCENARIO] Need different secrets per environment | Use environment secrets in repository settings | Environment-specific overrides for staging/production. |
| [GitHub Actions][SECURITY] How to prevent fork PR tampering? | Review code changes before approval | Never auto-approve; check workflow modifications. |
| [GitHub Actions][GOTCHA] Why does artifact download fail across workflows? | Artifacts scoped to workflow run | Use API or separate actions for cross-workflow sharing. |
| [GitHub Actions][CMD] What does `actions/checkout@v3` syntax mean? | Action at specific version/tag | Pin versions for reproducibility and security. |
| [GitHub Actions][SCENARIO] Timeout building large project | Increase `timeout-minutes` on job | Default 360 minutes; adjust per job needs. |
| [GitHub Actions][ADV] Reusable workflows vs composite actions? | Workflows for full jobs; actions for steps | Workflows called by jobs; actions called by steps. |
| [GitHub Actions][BEST PRACTICE] How to handle secrets rotation? | Update in repository settings; workflows auto-use | No workflow change needed; values updated centrally. |
| [GitHub Actions][SECURITY] How to scan dependencies for vulnerabilities? | Use `github/codeql-action` or Dependabot | Automated scanning on PRs and schedules. |
| [GitHub Actions][GOTCHA] Why does path filter not trigger workflow? | Paths evaluated after checkout | All changes trigger; paths filter jobs/steps. |
| [GitHub Actions][CMD] What does `if: ${{ github.event_name == 'push' }}` do? | Conditionally run based on trigger event | Filters execution by workflow trigger type. |

## 10. Prometheus

| Question | Answer | Explanation |
|---|---|---|
| [Prometheus][CMD] What does `rate(http_requests[5m])` calculate? | Per-second average over 5 minutes | Rate for counters; use for request rate. |
| [Prometheus][SCENARIO] Metrics missing for some targets | Check scrape errors in Prometheus targets page | Verify endpoint reachability and `/metrics` availability. |
| [Prometheus][GOTCHA] Why does `increase()` show decimals for counter? | Handles counter resets via extrapolation | Use `floor()` or round if integers needed. |
| [Prometheus][SECURITY] How to secure Prometheus metrics endpoint? | Use authentication proxy or network policies | Basic auth, mTLS, or firewall restrictions. |
| [Prometheus][CMD] Difference between `rate()` and `irate()`? | Rate averages; irate last two points | Rate smooth; irate volatile, sensitive spikes. |
| [Prometheus][BEST PRACTICE] How to label metrics for cardinality control? | Avoid high-cardinality labels like IDs | Use bounded values; IDs explode series count. |
| [Prometheus][SCENARIO] Alert fires but no notification received | Check Alertmanager configuration and routing | Verify routes match labels; check receiver config. |
| [Prometheus][GOTCHA] Why does `histogram_quantile` return unexpected values? | Need `rate()` before calculating quantile | Buckets must be rates: `histogram_quantile(0.95, rate(metric[5m]))`. |
| [Prometheus][CMD] What does `up{job="app"} == 0` query? | Targets down for job "app" | `up` metric 1 for healthy, 0 down. |
| [Prometheus][SECURITY] How to implement RBAC for Prometheus? | Use reverse proxy with authentication | Prometheus lacks native auth; proxy provides control. |
| [Prometheus][SCENARIO] High memory usage on Prometheus server | Reduce retention or scrape frequency | Memory grows with series and retention period. |
| [Prometheus][ADV] When to use recording rules? | Precompute expensive queries | Reduces query time; useful for dashboards. |
| [Prometheus][BEST PRACTICE] How to organize alerting rules? | Group by service with meaningful names | Separate files per service; clear alert names. |
| [Prometheus][GOTCHA] Why does counter reset break graph? | Counter reset on restart is normal | Use `rate()` which handles resets correctly. |
| [Prometheus][CMD] What does `promtool check rules` do? | Validates alerting/recording rule syntax | Catch errors before deploying to Prometheus. |
| [Prometheus][SCENARIO] Alert flapping between firing and resolved | Increase `for` duration in alert rule | Wait period before firing; reduces noise. |
| [Prometheus][SECURITY] How to encrypt scrape targets? | Enable HTTPS in scrape configuration | Use TLS with certificate verification. |
| [Prometheus][GOTCHA] Why does aggregation drop labels? | `sum()` without `by` removes all labels | Use `sum by (label)` to preserve needed. |
| [Prometheus][CMD] What does `absent(metric)` do? | Returns 1 if metric doesn't exist | Alert on missing metrics or targets. |
| [Prometheus][BEST PRACTICE] How to handle time series with gaps? | Set appropriate scrape intervals and timeouts | Configure retries; gaps indicate target issues. |
| [Prometheus][SCENARIO] Need to export metrics to long-term storage | Use remote write to external TSDB | Prometheus retention limited; use Thanos, Cortex. |
| [Prometheus][ADV] Push vs pull model tradeoffs? | Pull standard, simpler; push for short-lived | Pull for services; push with Pushgateway for batches. |
| [Prometheus][SECURITY] How to prevent metrics label injection? | Sanitize and validate labels at source | Relabeling configs can drop/modify labels. |
| [Prometheus][GOTCHA] Why does dashboard show no data? | Check time range and metric retention | Data outside retention period unavailable. |
| [Prometheus][CMD] What does `topk(5, metric)` do? | Returns top 5 series by value | Useful for highest resource consumers. |
| [Prometheus][SCENARIO] Scrape duration exceeds scrape interval | Increase interval or optimize target response | Target slow or returning too much data. |
| [Prometheus][BEST PRACTICE] How to version Prometheus configuration? | Store in version control with validation CI | Test changes with `promtool` before deploy. |
| [Prometheus][SECURITY] How to federate Prometheus servers securely? | Use TLS and authentication on federation endpoint | Hierarchical setup needs secure scraping. |
| [Prometheus][GOTCHA] Why does `avg()` not work as expected? | Missing values treated as 0 in aggregation | Use `avg_over_time()` for time-based averaging. |
| [Prometheus][CMD] What does `delta(metric[5m])` calculate? | Difference between first and last value | For gauges; shows change over time window. |
