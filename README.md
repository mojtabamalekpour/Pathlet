NAME: Mojtaba Malekpourshahraki

# Pathlet routing protocol

## Description

This program implements the pathlet protocol described in the 
Sigcomm '09 paper "Pathlet Routing".  The most notable aspect of the pathlet
routing is that, instead of carrying a set of ports (addresses), packets could
carry a mixture of pathlet and addresses. A pathlet contains a set of addresses.


### Pathlet routing details
Pathlet header format is as follows:

|   |   |   |
|---|---|---|
| PathletType : 0x8000 | size: 8 | [pathlet : 9] |
|   |   |   |

Note that each element in pathlet could contains either an address or a pathlet ID.
Size controls the number of items in the header (mixed pathlet items or ports).
Upon receiving a packet, a pathlet switch performs following operations:

 It checks if the very first item match with a pathlet ID in the table.
	- if matching fires, pathlet switch fetches the item and replace it with the ports provided by control plane.
	- if matching fails, pathlet switch use the number as a port for the output of the packet in the switch.

### Code limitations and future improvement
As I didn’t find loop in p4, I used multiple action tagged with 1,2,3,4 in the code to make p4 independent.

## Topology
I changed the topology from default source routing example to the following topology (first part of the homework):

```
s1     s2    s3    s4
 * --- * --- * --- * 
 |     |     |     |
 *     *     *     *
h1     h2    h3    h4
```

## Running the demo
We will run three different scenarios:
1. Sender adds a single pathlet. (e.g. pathlet 100 contains [2,3,3,1])
2. Sender adds two pathlets. (e.g. pathlet 100 contains [2,3] and pathlet 200 contains [3,1])
3. Senders adds a port and a pathlet. (e.g. port 2 and pathlet 100 contains [3,3,1])
4. Senders adds ONLY ports (no pathlet, e.g. [2 3 3 1])

### Sender adds a single pathlet:

1. Copy all files in the [single_pathlet] directory to the main directory.
2. In your shell, run:
   ```bash
   make
   ```
   his will:
   * compile `source_routing.p4`, and
   * start a Mininet instance with four switches (`s1`, `s2`, `s3`, `s4`) configured
     as shown in figure above, each connected to one host (`h1`, `h2`, `h3`, `h4`).
     Check the network topology using the `net` command in mininet.
     ```
     mininet> net
        h1 h1-eth0:s1-eth1
        h2 h2-eth0:s2-eth1
        h3 h3-eth0:s3-eth1
        h4 h4-eth0:s4-eth1
        s1 lo:  s1-eth1:h1-eth0 s1-eth2:s2-eth2
        s2 lo:  s2-eth1:h2-eth0 s2-eth2:s1-eth2 s2-eth3:s3-eth2
        s3 lo:  s3-eth1:h3-eth0 s3-eth2:s2-eth3 s3-eth3:s4-eth2
        s4 lo:  s4-eth1:h4-eth0 s4-eth2:s3-eth3

     ```
   * IP address for h1 is `10.0.1.1` and for h4 is `10.0.4.4`

3. Use the following command to open two terminals for
   `h1` and `h4`, respectively:
   ```bash
   mininet> xterm h1 h4
   ```
4. Each host includes a small Python-based messaging client and
   server. In `h4`'s xterm, start the server:
   ```bash
   ./receive.py
   ```
5. In `h1`'s xterm, send a message from the client:
   ```bash
   ./send.py 10.0.4.4
   ```

6. Type a single pathlet `100`.  This should send the
   pathlet to the `s1` and `s1` will compile it as a series of ports `2,3,3,1`.


### Sender adds two pathlets:
The difference is just in two steps 1 and 6:
1. Copy all files in the [multi_pathlet] directory to the main directory.

6. Type a single pathlet `100 200`.  This should send the
   pathlet 100 to the `s1` and `s1` will compile it as a series of ports `2,3`. Similarly, `s3` will compile it as `3,1` and the packet will be delivered to the destination.  


### Senders add a port and a pathlet.

1. Copy all files in the [mixed_pathlet_port] directory to the main directory.

6. Type a single pathlet `2 100`. In this case, packets will be forward to port `2` `(s2)` using a simple source routing. Then `s2` will compile pathlet `100`.
   
   
### Senders adds ONLY ports
1. Copy all files in the [mixed_pathlet_port] directory to the main directory.

6. Type a single pathlet `2 3 3 1`. it is EXACTLY source routing.

