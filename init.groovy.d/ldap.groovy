import com.michelin.cio.hudson.plugins.rolestrategy.RoleBasedAuthorizationStrategy;
import hudson.security.SecurityRealm;
import hudson.security.LDAPSecurityRealm;
import hudson.util.Secret;
import jenkins.security.plugins.ldap.FromGroupSearchLDAPGroupMembershipStrategy;
import jenkins.model.IdStrategy;
import jenkins.model.Jenkins;

def env = System.getenv()

/* configure LDAP security realm */
/* eg.
   LDAP_URL=ldap://ldap.example.com
   ROOT_DN=dc=example,dc=com
   LDAP_USER_SEARCH_BASE=  # not used
   LDAP_USER_SEARCH=mail={0}
   LDAP_GROUP_SEARCH_BASE=  # not used
   LDAP_GROUP_SEARCH_FILTER=   # not used
   LDAP_MANAGER_DN=cn=System,ou=people,dc=company,dc=com
   LDAP_MANAGER_KEY=<password for the LDAP_MANAGER_DN>
*/
def ldap_server = env.LDAP_URL
def ldap_rootDN = env.ROOT_DN
def ldap_userSearchBase = null //env['LDAP_USER_SEARCH_BASE']
def ldap_userSearch = 'mail={0}'
def ldap_groupSearchBase = null //env['LDAP_GROUP_SEARCH_BASE']
def ldap_groupSearchFilter = null //env['LDAP_GROUP_SEARCH_FILTER']
def ldap_groupMembershipFilter = null //env['LDAP_GROUP_MEMBERSHIP_FILTER']
def ldap_managerDN = env.LDAP_MANAGER_DN
def ldap_managerPassword = env.LDAP_MANAGER_KEY
def ldap_inhibitInferRootDN = true
def ldap_disableMailAddressResolver = false
def ldap_displayNameAttributeName = 'displayname'
def ldap_mailAddressAttributeName = 'mail'

/* get Jenkins instance reference */
def instance = Jenkins.getInstance()

/* create LDAPSecurityRealm instance with above configuration */
SecurityRealm ldap_realm = new LDAPSecurityRealm(
	ldap_server,
	ldap_rootDN,
	ldap_userSearchBase,
	ldap_userSearch,
	ldap_groupSearchBase,
	ldap_groupSearchFilter,
	ldap_groupMembershipFilter,
	ldap_managerDN,
	Secret.fromString(ldap_managerPassword),
	ldap_inhibitInferRootDN,
	ldap_disableMailAddressResolver,
	null,
	null,
	ldap_displayNameAttributeName,
	ldap_mailAddressAttributeName,
	IdStrategy.CASE_INSENSITIVE,
	IdStrategy.CASE_INSENSITIVE
) 

/* set the LDAP security realm for the Jenkins instance */
instance.setSecurityRealm(ldap_realm)

/* set Authorization strategy */
instance.setAuthorizationStrategy(new RoleBasedAuthorizationStrategy())

/* save the configuration */
instance.save()
