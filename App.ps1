Import-Module ActiveDirectory

function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

Add-Type -AssemblyName "PresentationFramework"

[xml]$xaml = Get-Content -Path (Join-Path -Path (Get-ScriptDirectory) -ChildPath  "MainWindow.xaml")
$reader = New-Object System.Xml.XmlNodeReader $xaml 
$window = [System.Windows.Markup.XamlReader]::Load($reader)

<# Custom variables #>
$username = $env:USERNAME
$currentUser = (Get-ADUser -Identity $username -Properties *)

<# Wire-up the UI #>
$txtFirstName = [System.Windows.Controls.TextBox]($window.FindName("txtFirstName"))
$txtLastName = [System.Windows.Controls.TextBox]($window.FindName("txtLastName"))
$txtMiddleName = [System.Windows.Controls.TextBox]($window.FindName("txtMiddleName"))
$txtDisplayName = [System.Windows.Controls.TextBox]($window.FindName("txtDisplayName"))
$txtLogonName = [System.Windows.Controls.TextBox]($window.FindName("txtLogonName"))
$cmbDomain = [System.Windows.Controls.ComboBox]($window.FindName("cmbDomain"))
$txtEmployeeId = [System.Windows.Controls.TextBox]($window.FindName("txtEmployeeId"))
$txtManager = [System.Windows.Controls.TextBox]($window.FindName("txtManager"))
$txtEmail = [System.Windows.Controls.TextBox]($window.FindName("txtEmail"))
$txtPhone = [System.Windows.Controls.TextBox]($window.FindName("txtPhone"))
$txtOffice = [System.Windows.Controls.TextBox]($window.FindName("txtOffice"))
$txtDescription = [System.Windows.Controls.TextBox]($window.FindName("txtDescription"))
$cmbHomeDrive = [System.Windows.Controls.ComboBox]($window.FindName("cmbHomeDrive"))
$txtHomeDirectory = [System.Windows.Controls.TextBox]($window.FindName("txtHomeDirectory"))
$btnSubmit = [System.Windows.Controls.Button]($window.FindName("btnSubmit"))

$btnSubmit.Add_Click({
    if(Set-ADUser -Identity $username -EmployeeID $txtEmployeeId.Text -PassThru) {
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
$txtManager.Text = (Get-ADUser -Identity $currentUser.Manager).Name
$txtEmail.Text = $currentUser.EmailAddress
$txtPhone.Text = $currentUser.OfficePhone
$txtOffice.Text = $currentUser.Office
$txtDescription.Text = $currentUser.Description
$cmbHomeDrive.SelectedValue = $currentUser.HomeDrive
$txtHomeDirectory.Text = $currentUser.HomeDirectory


<# Display the window #>
$window.ShowDialog()
