$session = New-PSSession -ComputerName WIN2008R2DC

$accelerator = [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
Add-Type -AssemblyName PresentationCore, PresentationFramework -PassThru | Where-Object IsPublic | ForEach-Object { $accelerator::Add($_.Name,$_) }

$currentDirectory = Split-Path $script:MyInvocation.MyCommand.Path

[xml]$xaml = Get-Content -Path (Join-Path -Path $currentDirectory -ChildPath  "MainWindow.xaml")
$reader = New-Object System.Xml.XmlNodeReader $xaml 
[Window]$window = [XamlReader]::Load($reader)


$window.FindName("MainFrame").Source = (Join-Path -Path $currentDirectory -ChildPath  "UserAdmin.xaml")
[xml]$xaml = Get-Content -Path (Join-Path -Path $currentDirectory -ChildPath  "UserAdmin.xaml")
$reader = New-Object System.Xml.XmlNodeReader $xaml 
$window.Content = [XamlReader]::Load($reader)

$content = $window.Content

<# Custom variables #>
$username = $env:USERNAME
$currentUser = Invoke-Command -Session $session -ScriptBlock { Get-ADUser -Identity $using:username -Properties * }

<# Wire-up the UI #>
$txtFirstName = [TextBox]($content.FindName("txtFirstName"))
$txtLastName = [TextBox]($content.FindName("txtLastName"))
$txtMiddleName = [TextBox]($content.FindName("txtMiddleName"))
$txtDisplayName = [TextBox]($content.FindName("txtDisplayName"))
$txtLogonName = [TextBox]($content.FindName("txtLogonName"))
$txtEmployeeId = [TextBox]($content.FindName("txtEmployeeId"))
$txtManager = [TextBox]($content.FindName("txtManager"))
$txtEmail = [TextBox]($content.FindName("txtEmail"))
$txtOffice = [TextBox]($content.FindName("txtOffice"))
$txtCell = [TextBox]($content.FindName("txtCell"))
$txtDescription = [TextBox]($content.FindName("txtDescription"))
$cmbHomeDrive = [ComboBox]($content.FindName("cmbHomeDrive"))
$txtHomeDirectory = [TextBox]($content.FindName("txtHomeDirectory"))
$btnSubmit = [Button]($content.FindName("btnSubmit"))

$btnSubmit.Add_Click({
    $props = @{
        Identity = $username
        EmployeeID = $txtEmployeeId.Text
        EmailAddress = $txtEmail.Text
        OfficePhone = $txtOffice.Text
        MobilePhone = $txtCell.Text
        Description = $txtDescription.Text
    }
    if($txtEmployeeId.Text -and (Invoke-Command -Session $session -ScriptBlock { Set-ADUser @using:props -PassThru })) {
        [MessageBox]::Show("Your request has successfully been submitted.", "Submitted", [MessageBoxButton]::OK, [MessageBoxImage]::Information)
    }
})

<# Custom logic #>
$txtFirstName.Text = $currentUser.GivenName
$txtLastName.Text = $currentUser.Surname
$txtMiddleName.Text = $currentUser.MiddleName
$txtDisplayName.Text = $currentUser.Name
$txtLogonName.Text = $currentUser.SamAccountName
$txtEmployeeId.Text = $currentUser.EmployeeID
if($currentUser.Manager) {
    $txtManager.Text = Invoke-Command -Session $session -ScriptBlock { Get-ADUser -Identity ($using:currentUser).Manager | Select-Object -ExpandProperty Name }
}
$txtEmail.Text = $currentUser.EmailAddress
$txtOffice.Text = $currentUser.OfficePhone
$txtCell.Text = $currentUser.MobilePhone
$txtDescription.Text = $currentUser.Description
if($currentUser.HomeDrive) {
    $cmbHomeDrive.SelectedValue = $currentUser.HomeDrive
}
$txtHomeDirectory.Text = $currentUser.HomeDirectory

<# Display the window #>
$window.ShowDialog() | Out-Null
