$session = New-PSSession -ComputerName WIN2008R2DC

Add-Type -AssemblyName "PresentationFramework","PresentationCore"


[xml]$xaml = Get-Content -Path (Join-Path -Path (Split-Path $script:MyInvocation.MyCommand.Path) -ChildPath  "MainWindow.xaml")
$reader = New-Object System.Xml.XmlNodeReader $xaml 
[System.Windows.Window]$window = [System.Windows.Markup.XamlReader]::Load($reader)


$window.FindName("MainFrame").Source = (Join-Path -Path (Split-Path $script:MyInvocation.MyCommand.Path) -ChildPath  "UserAdmin.xaml")
[xml]$xaml = Get-Content -Path (Join-Path -Path (Split-Path $script:MyInvocation.MyCommand.Path) -ChildPath  "UserAdmin.xaml")
$reader = New-Object System.Xml.XmlNodeReader $xaml 
$window.Content = [System.Windows.Markup.XamlReader]::Load($reader)

$content = $window.Content

<# Custom variables #>
$username = $env:USERNAME
$currentUser = Invoke-Command -Session $session -ScriptBlock { Get-ADUser -Identity $using:username -Properties * }

<# Wire-up the UI #>
$txtFirstName = [System.Windows.Controls.TextBox]($content.FindName("txtFirstName"))
$txtLastName = [System.Windows.Controls.TextBox]($content.FindName("txtLastName"))
$txtMiddleName = [System.Windows.Controls.TextBox]($content.FindName("txtMiddleName"))
$txtDisplayName = [System.Windows.Controls.TextBox]($content.FindName("txtDisplayName"))
$txtLogonName = [System.Windows.Controls.TextBox]($content.FindName("txtLogonName"))
$txtEmployeeId = [System.Windows.Controls.TextBox]($content.FindName("txtEmployeeId"))
$txtManager = [System.Windows.Controls.TextBox]($content.FindName("txtManager"))
$txtEmail = [System.Windows.Controls.TextBox]($content.FindName("txtEmail"))
$txtOffice = [System.Windows.Controls.TextBox]($content.FindName("txtOffice"))
$txtCell = [System.Windows.Controls.TextBox]($content.FindName("txtCell"))
$txtDescription = [System.Windows.Controls.TextBox]($content.FindName("txtDescription"))
$cmbHomeDrive = [System.Windows.Controls.ComboBox]($content.FindName("cmbHomeDrive"))
$txtHomeDirectory = [System.Windows.Controls.TextBox]($content.FindName("txtHomeDirectory"))
$btnSubmit = [System.Windows.Controls.Button]($content.FindName("btnSubmit"))

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
        [System.Windows.MessageBox]::Show("Your request has successfully been submitted.", "Submitted", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
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
