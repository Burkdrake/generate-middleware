# Generate Middleware

A blockchain-powered middleware platform for secure, decentralized service registration and activity tracking using the Stacks blockchain. This innovative solution provides a robust framework for creating verifiable, privacy-preserving service interactions.

## Overview

Generate Middleware creates an immutable, tamper-proof registry for service middleware interactions by storing cryptographic proofs on the Stacks blockchain. It addresses critical challenges in decentralized service management:

- Secure service registration and tracking
- Cryptographically verifiable service interactions
- Transparent and auditable middleware operations
- Privacy-preserving activity logging

Key features:
- Middleware service registration
- Dynamic service tracking
- Secure interaction logging with cryptographic attestations
- Comprehensive verification capabilities

## Architecture

The system consists of a single smart contract that manages service middleware registration and interaction logging. The architecture follows a flexible, extensible model where:

1. Services can register their middleware platform
2. Multiple service interactions can be tracked
3. Interactions are recorded as cryptographic attestations

```mermaid
graph TD
    A[Service Provider] -->|Registers| B[Middleware Platform]
    B -->|Manages| C[Service Interactions]
    C -->|Generates| D[Activity Logs]
    D -->|Stored as| E[Cryptographic Attestations]
    E -->|Verified by| B
```

## Contract Documentation

### middleware-registry

The main contract handling all IoT logging functionality.

#### Data Storage
- `nest-nodes`: Maps owner principals to NestNode information
- `devices`: Stores registered device information
- `activity-logs`: Contains cryptographic proofs of device activities
- `owner-devices`: Tracks all devices registered to each owner

#### Access Control
- Only registered NestNode owners can register devices and log activities
- Each device can only be registered once per owner
- Activity logs are immutable once recorded

## Getting Started

### Prerequisites
- Clarinet
- Stacks wallet
- NestNode system ID

### Installation

1. Clone the repository
2. Install dependencies with Clarinet
```bash
clarinet integrate
```

### Middleware Service Tracking

1. Register your NestNode:
```clarity
(contract-call? .home-iot-logger register-nest-node "your-nest-node-id")
```

2. Register an IoT device:
```clarity
(contract-call? .home-iot-logger register-device "device-id" "Living Room Camera" "security-camera")
```

3. Log device activity:
```clarity
(contract-call? .home-iot-logger log-device-activity "device-id" u1234567890 0x... 0x...)
```

## Function Reference

### Registration Functions

```clarity
(register-nest-node (nest-node-id (string-ascii 64)))
```
Registers a new NestNode system for the homeowner.

```clarity
(register-device (device-id (string-ascii 64)) (device-name (string-ascii 64)) (device-type (string-ascii 32)))
```
Registers a new IoT device to the homeowner's network.

### Logging Functions

```clarity
(log-device-activity (device-id (string-ascii 64)) (timestamp uint) (action-hash (buff 32)) (attestation-hash (buff 32)))
```
Records an activity attestation for a device.

### Query Functions

```clarity
(get-nest-node-info (owner principal))
(get-device-info (owner principal) (device-id (string-ascii 64)))
(get-owner-devices (owner principal))
(get-activity-log (owner principal) (device-id (string-ascii 64)) (timestamp uint))
```

### Verification Functions

```clarity
(verify-activity-attestation (owner principal) (device-id (string-ascii 64)) (timestamp uint) (provided-attestation-hash (buff 32)))
(was-device-active (owner principal) (device-id (string-ascii 64)) (timestamp uint))
```

## Development

### Testing

Run the test suite:
```bash
clarinet test
```

### Local Development
1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy contract:
```bash
clarinet deploy
```

## Security Considerations

### Limitations
- Maximum 100 devices per owner
- Activity logs are permanent and cannot be deleted
- Only hash-based attestations are stored on-chain

### Best Practices
- Generate strong, unique device IDs
- Securely store off-chain activity details
- Regularly verify activity attestations
- Keep NestNode credentials secure
- Implement proper hash generation for attestations

### Privacy
- No sensitive device data is stored on-chain
- Only cryptographic hashes are recorded
- Device activities can only be verified with knowledge of the original data