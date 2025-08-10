Add-Type -AssemblyName System.Windows.Forms,System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# META

function Get-TzePSVersion {
	return 1
}

# JOBS

function Clear-CompleteJobs {
	param (
		[bool]$PreserveFailed = $false
	)

	Get-Job | Where-Object { ($_.State -eq "Completed") -or (-not $PreserveFailed -and $_.State -eq "Failed") } | Remove-Job
}

# MESSAGE BOXES

function Show-MessageBoxSync {
	param (
		[string]$Content = "Content",
		[string]$Title = "Title",
		[System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
		[System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
	)
	
	return [System.Windows.Forms.MessageBox]::Show($Content, $Title, $Buttons, $Icon)
}

function Show-MessageBoxAsync {
	param (
		[string]$Content = "Content",
		[string]$Title = "Title",
		[System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
		[System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
	)
	
	return [System.Windows.Forms.MessageBox]::Show($Content, $Title, $Buttons, $Icon) &
}

# WINDOWS FORMS

function New-Form {
	param (
		[string]$Title = "Form",
		[int]$Width = 300,
		[int]$Height = 300,
		[bool]$AutoSize = $false,
		[System.Windows.Forms.AutoSizeMode]$AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowOnly,
		[System.Windows.Forms.FormStartPosition]$StartPosition = [System.Windows.Forms.FormStartPosition]::WindowsDefaultLocation,
		[bool]$MaximizeBox = $true,
		[bool]$MinimizeBox = $true,
		[System.Windows.Forms.FormBorderStyle]$FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
	)

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $Title
	$form.Width = $Width
	$form.Height = $Height
	$form.AutoSize = $AutoSize
	$form.AutoSizeMode = $AutoSizeMode
	$form.StartPosition = $StartPosition
	$form.MaximizeBox = $MaximizeBox
	$form.MinimizeBox = $MinimizeBox
	$form.FormBorderStyle = $FormBorderStyle

	return $form
}

function New-FormLabel {
	param (
		[string]$Text = "Label",
		[int]$X = 0,
		[int]$Y = 0
	)

	$label = New-Object System.Windows.Forms.Label
	$label.Text = $Text
	$label.Location = New-Object System.Drawing.Point($X, $Y)
	$label.AutoSize = $true

	return $label
}

function New-FormButton {
	param (
		[string]$Text = "Button",
		[int]$X = 0,
		[int]$Y = 0,
		[int]$Width = 75,
		[int]$Height = 30,
		[bool]$AutoSize = $false,
		[System.Windows.Forms.AutoSizeMode]$AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowOnly,
		[System.Windows.Forms.DialogResult]$DialogResult = [System.Windows.Forms.DialogResult]::None,
		[scriptblock]$OnClick = $null
	)

	$button = New-Object System.Windows.Forms.Button
	$button.Text = $Text
	$button.Location = New-Object System.Drawing.Point($X, $Y)
	$button.Size = New-Object System.Drawing.Size($Width, $Height)
	$button.AutoSize = $AutoSize
	$button.AutoSizeMode = $AutoSizeMode
	$button.DialogResult = $DialogResult
	if ($OnClick -ne $null) { $button.add_Click($OnClick) }

	return $button
}

function New-FormTextBox {
	param (
		[int]$X = 0,
		[int]$Y = 0,
		[int]$Width = 75,
		[int]$Height = 30,
		[bool]$Multiline = $false,
		[string]$PlaceholderText = ""
	)
	
	$box = New-Object System.Windows.Forms.TextBox
	$box.Location = New-Object System.Drawing.Point($X, $Y)
	$box.Size = New-Object System.Drawing.Size($Width, $Height)
	$box.Multiline = $Multiline
	$box.PlaceholderText = $PlaceholderText
	$box.BorderStyle = "FixedSingle"

	return $box
}

function New-FormCheckBox {
	param (
		[string]$Text = "Checkbox",
		[int]$X = 0,
		[int]$Y = 0,
		[bool]$Checked = $false
	)
	
	$cbox = New-Object System.Windows.Forms.CheckBox
	$cbox.Text = $Text
	$cbox.Location = New-Object System.Drawing.Point($X, $Y)
	$cbox.AutoSize = $true
	$cbox.Checked = $Checked

	return $cbox
}

# SIMPLE FORM BUILDER
class SimpleFormBuilder {
	[object] $Form

	SimpleFormBuilder([object] $Form) {
		$this.Form = $Form
	}

	[int] GetNextControlY() {
		$ret = 10
		$this.Form.Controls | ForEach-Object {
			$ret += $_.Height + 10
		}
		return $ret
	}

	static [SimpleFormBuilder] Create([string] $Title) {
		$f = New-Form -Title $Title -AutoSize $true -AutoSizeMode GrowAndShrink -StartPosition CenterScreen -MaximizeBox $false -FormBorderStyle FixedDialog
		$f.Padding = 10
		return New-Object SimpleFormBuilder($f)
	}

	[SimpleFormBuilder] Label([string] $Text) {
		$l = New-FormLabel -Text $Text -X 10 -Y $this.GetNextControlY()
		$this.Form.Controls.Add($l)
		return $this
	}

	[SimpleFormBuilder] Button([string] $Text, [object] $DialogResult, [scriptblock] $OnClick) {
		$l = New-FormButton -Text $Text -X 10 -Y $this.GetNextControlY() -AutoSize $true -DialogResult $DialogResult -OnClick $OnClick
		$this.Form.Controls.Add($l)
		return $this
	}

	[SimpleFormBuilder] TextBox([bool] $Multiline, [string] $PlaceholderText) {
		$box = New-FormTextBox -X 10 -Y $this.GetNextControlY() -Width 200 -Height 100 -Multiline $Multiline -PlaceholderText $PlaceholderText
		$this.Form.Controls.Add($box)
		return $this
	}

	[SimpleFormBuilder] CheckBox([string] $Text, [bool] $Checked) {
		$cbox = New-FormCheckBox -Text $Text -X 10 -Y $this.GetNextControlY() -Checked $Checked
		$this.Form.Controls.Add($cbox)
		return $this
	}

	[object] GetControl([int] $Index) {
		return $this.Form.Controls[$Index];
	}

	[object] ShowDialog() {
		return $this.Form.ShowDialog()
	}
}
