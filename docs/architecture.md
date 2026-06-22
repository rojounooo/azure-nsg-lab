# Architecture

## Overview

This lab simulates a two-tier segmented network consisting of a web tier and a data tier. The web tier is exposed to the internet and accepts inbound HTTP/HTTPS and SSH from a designated management IP. The data tier is fully isolated from the internet and accepts traffic from the web tier only. NSGs on each subnet enforce the boundary between tiers and control all inbound and outbound traffic flow.

---

## Diagram

```mermaid
flowchart TD
    Internet([Internet])
    subgraph vnet["vnet-nsg-lab (10.0.0.0/16)"]
        subgraph snet-web["snet-web (10.0.1.0/24)"]
            nsg-web["nsg-web\nAllow HTTP/HTTPS\nAllow SSH from personal IP\nDeny all other inbound"]
            vm-web["vm-web\n10.0.1.4\nPublic IP: 20.91.212.124"]
        end
        subgraph snet-data["snet-data (10.0.2.0/24)"]
            nsg-data["nsg-data\nAllow from snet-web only\nDeny internet inbound\nDeny internet outbound"]
            vm-data["vm-data\n10.0.2.4\nNo public IP"]
        end
    end

    Internet -->|"Allow 80, 443\nAllow SSH mgmt IP"| nsg-web
    nsg-web --> vm-web
    vm-web -->|"Allow from 10.0.1.0/24"| nsg-data
    nsg-data --> vm-data
    Internet -..->|"Denied"| snet-data
```

---

## Design Decisions

**NSGs are attached at the subnet level rather than per NIC.** Subnet-level attachment is simpler to manage and scales better when additional VMs are added to a tier. Any new VM in the subnet inherits the rules automatically, with no per-NIC configuration required. It also makes the tier boundary explicit and visible at the network level.

**vm-data has no public IP.** Without a public IP there is no route from the internet to the VM, meaning it cannot be reached from outside the VNet regardless of NSG rules. The NSG rules on `snet-data` add a second layer on top of this.

**Separate NSGs per subnet rather than a shared NSG.** Each tier has different traffic requirements so each gets its own NSG with rules scoped to that tier. A shared NSG would accumulate rules for both tiers, increasing complexity and the risk of an overly permissive rule unintentionally applying to the wrong subnet.
