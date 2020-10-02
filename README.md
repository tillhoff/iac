# iac
The code needed to deploy my homelab infrastructure.

## lab setup
- installed debian 10
- configured with ansible and playbook `debian_10_server.yml` from https://github.com/tillhoff/automated-deployment.
- set dns entries (see [networking](#public) and caddyfile from `helm/caddy/values.yaml`)
- run `task deploy`

## networking

### public
- alpha-centauri.enforge.de
- alpha.enforge.de
- pw.enforge.de
- push.enforge.de
- vpn.enforge.de

## parts/folders

- **ansible**: Contains ansible-playbooks
  - **entry-point**: provision entry-point for minikube on alpha-centauri
  - **router**: provision vpn-server on alpha-centauri               |
- **helm**: Contains helm charts
- **kubernetes**: Contains global kubernetes configuration
