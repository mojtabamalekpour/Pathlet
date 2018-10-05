/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<16> TYPE_PATHLET = 0x8000;

#define MAX_HOPS 9

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header pathLet_t {
    bit<1>    bos;
    bit<15>   item;
    bit<8>    size;
}


header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}



struct pl_metadata_t {
    bit<8>  pathLetSize;
}

struct metadata {
    pl_metadata_t   pl_metadata;
}

struct headers {
    ethernet_t              ethernet;
    pathLet_t[MAX_HOPS]     pathLets;
    ipv4_t                  ipv4;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        meta.pl_metadata.pathLetSize = (bit<8>) hdr.pathLets.size;
        transition select(hdr.ethernet.etherType) {
            TYPE_PATHLET: parse_pathlet;
            default: accept;
        }
    }


    state parse_pathlet { 
        packet.extract(hdr.pathLets.next);
        transition select(hdr.pathLets.last.bos) {
            1: parse_ipv4;
            default: parse_pathlet;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    action drop() {
        //mark_to_drop();
    }
    

    action pathlet_to_port4(bit<15> items,bit<15> items1,bit<15> items2,bit<15> items3) {
        hdr.pathLets.pop_front(1);
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items3;
        if(meta.pl_metadata.pathLetSize == 1){
            if(hdr.pathLets[0].item < 99){
                hdr.pathLets[0].bos = 1;    
            }else{
                hdr.pathLets[0].bos = 0;    
            }
        }
        
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items2;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;

        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items1;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;

        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;
    }


    action pathlet_to_port3(bit<15> items1,bit<15> items2,bit<15> items3) {
        hdr.pathLets.pop_front(1);
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items3;
        if(meta.pl_metadata.pathLetSize == 1){
            if(hdr.pathLets[0].item < 99){
                hdr.pathLets[0].bos = 1;    
            }else{
                hdr.pathLets[0].bos = 0;    
            }
        }
        
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items2;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;

        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items1;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;

    }


    action pathlet_to_port2(bit<15> items2,bit<15> items3) {
        hdr.pathLets.pop_front(1);
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items3;
        if(meta.pl_metadata.pathLetSize == 1){
            if(hdr.pathLets[0].item < 99){
                hdr.pathLets[0].bos = 1;    
            }else{
                hdr.pathLets[0].bos = 0;    
            }
        }
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items2;
        hdr.pathLets[0].bos = 0;
        meta.pl_metadata.pathLetSize = meta.pl_metadata.pathLetSize + 1;
    }

    action pathlet_to_port1(bit<15> items3) {
        hdr.pathLets.pop_front(1);
        
        hdr.pathLets.push_front(1);
        hdr.pathLets[0].setValid();
        hdr.pathLets[0].item = items3;
        if(meta.pl_metadata.pathLetSize == 1){
            if(hdr.pathLets[0].item < 99){
                hdr.pathLets[0].bos = 1;    
            }else{
                hdr.pathLets[0].bos = 0;    
            }
        }
    }


    table flowlet_table {
        key = {
           hdr.pathLets[0].item: exact;    
        }
        actions = {
            pathlet_to_port4;
            pathlet_to_port3;
            pathlet_to_port2;
            pathlet_to_port1;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    action srcRoute_nhop() {
            standard_metadata.egress_spec = (bit<9>)hdr.pathLets[0].item;
            hdr.pathLets.pop_front(1); 
    }
    
    apply {
        if (hdr.pathLets[0].isValid()){
           
            if (hdr.pathLets[0].item == 1){
               hdr.ethernet.etherType = TYPE_IPV4;
            }
            flowlet_table.apply();
            srcRoute_nhop();
            
            if (hdr.ipv4.isValid()){
                hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
            }
        }else{
            drop();
        } 
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
    apply {
 
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.pathLets);
        packet.emit(hdr.ipv4);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
