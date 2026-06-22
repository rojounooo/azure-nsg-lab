# azure-nsg-lab

A hands-on Azure lab demonstrating Network Security Group (NSG) design, subnet segmentation, and traffic flow verification across a two-tier network architecture.

## Overview

This lab provisions a Virtual Network (`vnet-nsg-lab`) in Sweden Central with two subnets — a web tier (`snet-web`) and a data tier (`snet-data`). Each subnet has a dedicated NSG with rules that enforce strict traffic control: the web tier accepts inbound HTTP/HTTPS from the internet and SSH from a management IP only, while the data tier accepts traffic exclusively from the web subnet and is fully isolated from the internet.

The lab covers NSG rule design, subnet-level NSG association, effective security rule auditing, and systematic traffic verification using manual tests.

## Notes

- Sweden Central used because the B-series VMs are unavailable in UK South under the Free Tier. 

- NSGs attached at the subnet level enforce rules consistently across all VMs in that subnet without relying on per-NIC configuration — this is the preferred enterprise pattern.

- NSGs are stateful, so allowing inbound traffic on a port implicitly allows the return traffic without needing a separate outbound rule.

- A VM with no public IP cannot be reached directly from the internet regardless of NSG rules — the two controls are independent layers of defence.

- Using cloud shell to create VMs with SSH Key Authentication can cause problems on Windows hosts. I used passwords and then added SSH auth later.

- For cleanup, simply delete the resource group via Portal, CLI or Powershell

## Repo structure

```
azure-nsg-lab/
├── README.md
├── docs/
│   ├── architecture.md           # topology overview and design decisions
│   └── traffic-verification.md   # test commands, outputs, and rule explanations
├── screenshots/
└──  scripts/
```
