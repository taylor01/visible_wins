# ServiceNow Ticket: Okta OIDC Configuration for Visible Wins Application

## Ticket Information
- **Category:** Identity & Access Management
- **Subcategory:** OIDC Application Configuration
- **Priority:** Medium
- **Urgency:** Medium
- **Assignment Group:** Identity Management Team

---

## REQUEST SUMMARY
Configure Okta OIDC application integration for the new "Visible Wins" IT team schedule tracking application to enable Single Sign-On (SSO) authentication.

## BUSINESS JUSTIFICATION
The IT department has developed a new internal application for tracking team schedules and work locations. This application requires integration with our corporate Okta instance to:
- Eliminate separate password management for users
- Leverage existing corporate credentials for authentication
- Automatically provision users with their organizational data
- Maintain consistent security standards across all internal applications

## CONFIGURATION REQUIREMENTS

### Application Details
- **Application Name:** Visible Wins
- **Application Type:** Web Application (Server-side)
- **Application URL:** `https://visible-wins.company.com` (or staging URL)
- **Application Description:** IT team schedule tracking and management system

### OIDC Configuration Parameters
- **Grant Types:** Authorization Code
- **Response Types:** code
- **Token Endpoint Authentication:** client_secret_post
- **Application Logo:** (To be provided by IT team)

### Redirect URIs
**Production:**
- `https://visible-wins.company.com/auth/okta/callback`

**Staging/Development:** 
- `https://visible-wins-staging.company.com/auth/okta/callback`
- `http://localhost:3000/auth/okta/callback` (for local development)

### Required Scopes
- `openid` (required for OIDC)
- `email` (user email address)
- `profile` (basic user profile information)
- `groups` (user group memberships for team assignment)

### Custom Claims Configuration
Please configure the following custom claims to be included in the ID token:

| Claim Name | Okta Attribute | Purpose |
|------------|----------------|---------|
| `employee_number` | user.employeeNumber | Unique employee identifier |
| `department` | user.department | Department for team assignment |
| `title` | user.title | Job title for role mapping |
| `manager` | user.manager | Manager email for hierarchy |
| `phone_number` | user.mobilePhone | Contact information |
| `office_location` | user.city | Office location |
| `hire_date` | user.hireDate | Employee start date |
| `employee_type` | user.employeeType | Full-time/Part-time/Contractor |
| `groups` | user.groups | Group memberships |

### Group Mappings for Auto-Assignment
The application will use the following group mappings for automatic team assignment and admin privileges:

**Team Assignment Groups:**
- `IT-Development` → Development Team
- `IT-Infrastructure` → Operations Team  
- `IT-Security` → Security Team
- `IT-Support` → Support Team

**Admin Privilege Groups:**
- `IT-Admins` → Full admin access
- `IT-Managers` → Admin access
- `Administrators` → Admin access

### User Assignment
- **Assignment:** Manual assignment initially
- **Scope:** IT Department users only (approximately 65 users)
- **Auto-Assignment:** Consider enabling for IT-* groups after initial testing

## DELIVERABLES REQUESTED

1. **OIDC Application Configuration**
   - Configured Okta application with above specifications
   - Generated Client ID and Client Secret

2. **Custom Claims Setup**
   - All custom claims mapped to appropriate user attributes
   - Claims included in ID token responses

3. **Group Integration**
   - Verification that group memberships are properly included in tokens
   - Documentation of any group name mappings required

4. **Testing Credentials**
   - Client ID and Client Secret for staging environment
   - Test user account with appropriate group memberships

5. **Documentation**
   - Okta application configuration summary
   - Instructions for managing user assignments
   - Troubleshooting guide for common issues

## ENVIRONMENT VARIABLES TO BE PROVIDED
Upon completion, please provide the following configuration values:

```
OKTA_ISSUER_URL=https://company.okta.com/oauth2/default
OKTA_CLIENT_ID=[generated_client_id]
OKTA_CLIENT_SECRET=[generated_client_secret]
```

## TESTING REQUIREMENTS
- Successful authentication flow with test user
- Verification that all custom claims are populated
- Confirmation that group memberships are correctly passed
- Testing of both user creation and user update scenarios

## TIMELINE
- **Requested Completion:** Within 5 business days
- **Testing Window:** 2 business days after configuration
- **Go-Live Date:** Following successful testing

## SECURITY CONSIDERATIONS
- Application follows OIDC security best practices
- Client secret will be securely stored in application environment variables
- No user passwords will be stored in the application database
- All authentication will be handled through Okta

## STAKEHOLDERS
- **Requestor:** [IT Team Lead Name]
- **Technical Contact:** [Developer Name] 
- **Business Owner:** [IT Director Name]
- **Security Reviewer:** [Security Team Contact]

## ADDITIONAL NOTES
This application replaces manual schedule tracking processes and will improve visibility into team availability for better resource planning. The OIDC integration is critical for user adoption as it eliminates the need for users to manage another set of credentials.

---

**Please assign this ticket to the Identity Management team and provide an estimated completion date.**