$RequiredScopes = @("Directory.AccessAsUser.All", "Directory.ReadWrite.All", "User.ReadWrite.All", “User.Read.All”)

Connect-MgGraph -Scopes $RequiredScopes

$user = user1@example.com
$method = Get-MgUserAuthenticationPasswordMethod -UserId $user
  
Reset-MgUserAuthenticationMethodPassword -UserId $user -RequireChangeOnNextSignIn -AuthenticationMethodId $method.id -NewPassword "temporarypassword2!" 






