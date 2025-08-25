# Commercial Trucking Fleet Management & Compliance System

A comprehensive blockchain-based fleet management system built on Stacks using Clarity smart contracts. This system provides complete trucking fleet operations management including driver compliance, vehicle maintenance, fuel tracking, route coordination, and safety reporting.

## System Overview

The system consists of five interconnected smart contracts that handle different aspects of fleet management:

### 1. Driver Management Contract (`driver-management.clar`)
- Driver registration and profile management
- Hours of Service (HOS) tracking and compliance
- Driver certification and license management
- Violation tracking and penalties

### 2. Vehicle Management Contract (`vehicle-management.clar`)
- Vehicle registration and fleet inventory
- Maintenance scheduling and tracking
- Inspection records and compliance
- Vehicle status and availability management

### 3. Fuel Management Contract (`fuel-management.clar`)
- Fuel consumption tracking per vehicle/driver
- Fuel efficiency analytics and optimization
- Fuel card transaction recording
- Cost analysis and reporting

### 4. Route Management Contract (`route-management.clar`)
- Route planning and optimization
- Delivery coordination and scheduling
- Load assignment and tracking
- Performance metrics and analytics

### 5. Safety Management Contract (`safety-management.clar`)
- Incident reporting and investigation
- Safety score tracking
- Compliance monitoring
- Risk assessment and mitigation

## Key Features

### Compliance & Regulatory
- **Hours of Service (HOS) Monitoring**: Automatic tracking of driver work hours with DOT compliance
- **Vehicle Inspections**: Scheduled maintenance and safety inspections
- **Safety Reporting**: Comprehensive incident tracking and investigation workflows
- **Regulatory Compliance**: Built-in compliance checks for DOT, FMCSA, and state regulations

### Operational Efficiency
- **Real-time Tracking**: Vehicle location and status monitoring
- **Route Optimization**: Intelligent route planning for fuel efficiency
- **Maintenance Scheduling**: Predictive maintenance based on usage patterns
- **Performance Analytics**: Comprehensive reporting and KPI tracking

### Financial Management
- **Fuel Cost Tracking**: Detailed fuel consumption and cost analysis
- **Maintenance Cost Management**: Tracking of all vehicle-related expenses
- **Driver Performance Metrics**: Efficiency and safety scoring
- **ROI Analytics**: Fleet performance and profitability analysis

## Data Structures

### Driver Records
- Personal information and certifications
- Hours of service logs with automatic compliance checking
- Performance metrics and safety scores
- Violation history and penalty tracking

### Vehicle Records
- Vehicle specifications and registration details
- Maintenance history and scheduling
- Inspection records and compliance status
- Fuel consumption and efficiency metrics

### Route Records
- Origin, destination, and waypoint management
- Load details and delivery requirements
- Performance metrics and completion status
- Cost analysis and profitability tracking

## Security Features

- **Access Control**: Role-based permissions for different user types
- **Data Integrity**: Immutable record keeping on blockchain
- **Audit Trail**: Complete transaction history for compliance
- **Privacy Protection**: Sensitive data encryption and access controls

## Getting Started

1. **Setup Environment**
   \`\`\`bash
   npm install
   clarinet check
   \`\`\`

2. **Deploy Contracts**
   \`\`\`bash
   clarinet deploy --testnet
   \`\`\`

3. **Run Tests**
   \`\`\`bash
   npm test
   \`\`\`

## Contract Interactions

Each contract provides public functions for:
- Data creation and updates
- Query operations for reporting
- Compliance checking and validation
- Administrative functions for fleet managers

## Compliance Standards

The system is designed to meet:
- **DOT Hours of Service Regulations**
- **FMCSA Safety Management Standards**
- **State and Federal Transportation Laws**
- **Environmental Compliance Requirements**

## Technology Stack

- **Blockchain**: Stacks Network
- **Smart Contracts**: Clarity Language
- **Testing**: Vitest Framework
- **Development**: Clarinet CLI

## Support & Documentation

For detailed API documentation, deployment guides, and troubleshooting, please refer to the individual contract files and test suites included in this repository.
