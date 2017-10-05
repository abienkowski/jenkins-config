import com.michelin.cio.hudson.plugins.rolestrategy.Role;
import com.michelin.cio.hudson.plugins.rolestrategy.RoleBasedAuthorizationStrategy;
import hudson.security.Permission;
import jenkins.model.Jenkins;

/* get Jenkins instance reference */
def instance = Jenkins.getInstance();

/* check if RoleBasedAuthorizationStrategy is already configured so it does not get overritten */
def currentAuthorizationStrategy = instance.getAuthorizationStrategy();
if (currentAuthenticationStrategy instanceof RoleBasedAuthorizationStrategy) {
  println "Role based authorisation already enabled."
  println "Exiting script..."
} else {
  /* check for the initial user to be added to the admin role */
  def env = System.getenv();
  def sid = env.ADMIN_USERNAME;

  /* create RoleBasedAuthorizationStrategy instance */
  def roleBasedAuthorization = new RoleBasedAuthorizationStrategy();
  /* create admin set of permissions */
  Set<Permission> adminPermissions = new HashSet<Permission>();
  adminPermissions.add(Permission.fromId("hudson.model.View.Delete"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Connect"));
  adminPermissions.add(Permission.fromId("hudson.model.Run.Delete"));
  adminPermissions.add(Permission.fromId("hudson.model.Hudson.UploadPlugins"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Create"));
  adminPermissions.add(Permission.fromId("hudson.model.View.Configure"));
  adminPermissions.add(Permission.fromId("hudson.model.Hudson.ConfigureUpdateCenter"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Build"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Configure"));
  adminPermissions.add(Permission.fromId("hudson.model.Hudson.Administer"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Cancel"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Read"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Delete"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Build"));
  adminPermissions.add(Permission.fromId("hudson.scm.SCM.Tag"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Discover"));
  adminPermissions.add(Permission.fromId("hudson.model.Hudson.Read"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Create"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Move"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Workspace"));
  adminPermissions.add(Permission.fromId("hudson.model.View.Read"));
  adminPermissions.add(Permission.fromId("hudson.model.Hudson.RunScripts"));
  adminPermissions.add(Permission.fromId("hudson.model.View.Create"));
  adminPermissions.add(Permission.fromId("hudson.model.Item.Delete"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Configure"));
  adminPermissions.add(Permission.fromId("hudson.model.Computer.Disconnect"));
  adminPermissions.add(Permission.fromId("hudson.model.Run.Update"));

  /* create the admin role */
  Role adminRole = new Role('admin', adminPermissions);
  roleBasedAuthorization.addRole(RoleBasedAuthorizationStrategy.GLOBAL, adminRole);

  /* assign admin role to the selected user */
  roleBasedAuthorization.doAssignRole(
  	RoleBasedAuthorizationStrategy.GLOBAL,
  	'admin',
  	sid
  );

  /* set Authorization strategy */
  instance.setAuthorizationStrategy(roleBasedAuthorization)

  /* save the configuration */
  instance.save()
}
