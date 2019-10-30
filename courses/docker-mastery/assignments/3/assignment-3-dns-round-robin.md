# Assignment 3 - DNS Round Robin

We can have multiple containers on a created network respond to the same DNS address.

Goals:

- Create a new virtual network (default bridge driver)
- Create 2 containers from **elasticsearch:2** image
- Use **-network-alias search** when creating these containers to give them an additional DNS name
- Run **alpine nslookup search** with **--net** to see the 2 containers list for the same DNS name
- Run **centos curl -s search:9200** with **--net** multiple times until you see both *name* fields

```bash
➜ docker network create dns-network
3a0835739d524438e9b4b1ff33c61ec9978b35ff9b7730ef236f0fd8a5578107

➜ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
39a423480e76        bridge              bridge              local
3a0835739d52        dns-network         bridge              local
297d1ec24777        host                host                local
eaf9d78e3ee4        none                null                local

➜ docker container run --name elasticsearch1 -it -d --network=dns-network --network-alias search elasticsearch:2
13be99f1ed1906f28a19422ed7ca9242ddd272e2a6c1a0daecddcd48a20321c4

➜ docker container run --name elasticsearch2 -it -d --network=dns-network --network-alias search elasticsearch:2
255b67366de330f344a528abcb96193102962ab7900044ea539cb562859ea43b

➜ docker container run --name alpine -it --rm --net=dns-network alpine nslookup search
Name:        search
Address 1:   172.18.0.3 elasticsearch2.dns-network
Address 2:   172.18.0.2 elasticsearch1.dns-network

➜ docker container run --name centos -it --rm --net=dns-network centos curl -s search:9200
{
  "name" : "Star Thief",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "2bEeTdtbRpaRLBEs5ywI0Q",
  "version" : {
    "number" : "2.4.6",
    "build_hash" : "5376dca9f70f3abef96a77f4bb22720ace8240fd",
    "build_timestamp" : "2017-07-18T12:17:44Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.4"
  },
  "tagline" : "You Know, for Search"
}

➜ docker container run --name centos -it --rm --net=dns-network centos curl -s search:9200
{
  "name" : "Jaeger",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "tNxzbzIHRvuMJeR6t3Aapg",
  "version" : {
    "number" : "2.4.6",
    "build_hash" : "5376dca9f70f3abef96a77f4bb22720ace8240fd",
    "build_timestamp" : "2017-07-18T12:17:44Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.4"
  },
  "tagline" : "You Know, for Search"
}

➜ docker container run --name centos -it --rm --net=dns-network centos curl -s search:9200
{
  "name" : "Star Thief",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "2bEeTdtbRpaRLBEs5ywI0Q",
  "version" : {
    "number" : "2.4.6",
    "build_hash" : "5376dca9f70f3abef96a77f4bb22720ace8240fd",
    "build_timestamp" : "2017-07-18T12:17:44Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.4"
  },
  "tagline" : "You Know, for Search"
}
```

