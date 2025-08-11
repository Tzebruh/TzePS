# TzePS

TzePS is a PowerShell library that aims to simplify some of the otherwise complex tasks in PowerShell, like message boxes or form creation.

## Contributing

Contributions are welcome! All I ask is you try to keep the file categorized, (I've set a low bar) that you increment the version number in Get-TzePSVersion, and that your commit title starts with the new version number in brackets. (Example: `[2] Fixed a bug in ...`) If you are not changing the library itself, mark your commit with the current version and a letter like `[2a]` instead.

## Importing

Due to having a class, TzePS cannot be imported as a module. Instead you must dot-source it. If you download TzePS.ps1, this can be done with `. .\TzePS.ps1`. If you wish to import it from the internet, you can do so with the following snippet, though it would require internet access each time your script is run.

```pwsh
. ([scriptblock]::Create((Invoke-WebRequest https://raw.githubusercontent.com/Tzebruh/TzePS/main/TzePS.ps1 -UseBasicParsing).Content))
```

## Functions

> Note: all function parameters are optional and their default values are listed here.

### Get-TzePSVersion
#### Returns the version number of TzePS. This is a basic integer that should increment every commit.

```pwsh
Get-TzePSVersion
```

### Clear-CompleteJobs
#### Clears any jobs that are complete, optionally preserving failed jobs.

```pwsh
Clear-CompleteJobs -PreserveFailed $false
```

### Show-MessageBoxSync
#### Shows a message box, blocking the current thread and returning the DialogResult.

```pwsh
Show-MessageBoxSync -Content "Content" -Title "Title" -Buttons OK -Icon None
```

### Show-MessageBoxAsync
#### Shows a message box in a new job, allowing the current thread to continue and returning the created job.

```pwsh
Show-MessageBoxAsync -Content "Content" -Title "Title" -Buttons OK -Icon None
```

### New-Form
#### Creates and returns a new Windows Form.
> Note: If you don't need much customization over your form, consider using SimpleFormBuilder instead.

```pwsh
New-Form -Title "Form" -Width 300 -Height 300 -AutoSize $false -AutoSizeMode GrowOnly -StartPosition WindowsDefaultLocation -MaximizeBox $true -MinimizeBox $true -FormBorderStyle Sizable
```

### New-FormLabel
#### Creates and returns a new Label control for use in Windows Forms.

```pwsh
New-FormLabel -Text "Label" -X 0 -Y 0
```

### New-FormButton
#### Creates and returns a new Button control for use in Windows Forms. The DialogResult parameter allows the button to close the form and return a DialogResult, (if the form was opened with ShowDialog) and the OnClick parameter allows the button to run a PowerShell script block when clicked.

```pwsh
New-FormButton -Text "Button" -X 0 -Y 0 -Width 75 -Height 30 -AutoSize $false -AutoSizeMode GrowOnly -DialogResult None -OnClick $null
```

### New-FormTextBox
#### Creates and returns a new TextBox control for use in Windows Forms. AutoSize on text boxes only sizes the height of single line text boxes. Therefore, width should still be considered and height may be disregarded when making single line text boxes. When making multi line text boxes, AutoSize has no effect.

```pwsh
New-FormTextBox -X 0 -Y 0 -Width 75 -Height 30 -Multiline $false -PlaceholderText ""
```

### New-FormCheckBox
#### Creates and returns a new CheckBox control for use in Windows Forms.

```pwsh
New-FormCheckBox -Text "Checkbox" -X 0 -Y 0 -Checked $false
```

## SimpleFormBuilder

SimpleFormBuilder is a class that allows you to build simple Windows Forms without worrying about layout. The controls are laid out top-to-bottom in the order they were added, and each element is 10px away from each other and the border of the form. The form size is based on the size of its contents with a 10px padding.

### SimpleFormBuilder(object Form)
Creates a SimpleFormBuilder around an existing form. For most purposes, you should use `[SimpleFormBuilder]::Create` instead.

### int GetNextControlY()
Gets the Y position to be used for the next control. Primarily used internally, but it is open to be used manually if needed.

### static SimpleFormBuilder Create(string Title)
A static method that creates the builder. The builder is initialized with an empty form with the given title.

### SimpleFormBuilder Label(string Text)
Adds a label to the form with the given content.

### SimpleFormBuilder Button(string Text, object DialogResult, scriptblock OnClick)
Adds a button to the form with the given text. DialogResult must be passed as an object due to PowerShell class limitations, so `None` will not suffice. You must instead use `"None"`. The OnClick parameter may be `$null`, but it may not be omitted.

### SimpleFormBuilder TextBox(bool Multiline, string PlaceholderText)
Adds a text box to the form with width 200 and height 100. If single line, auto size controls the height. PlaceholderText may be `""`, but it may not be omitted.

### SimpleFormBuilder CheckBox(string Text, bool Checked)
Adds a checkbox to the form with the given text and starting state.

### object GetControl(int Index)
Returns the control in the form at the given index, starting at 0. Shorthand for `.Form.Controls[$Index]`.

### object ShowDialog()
Shows the form as a dialog, returning a DialogResult. Shorthand for `.Form.ShowDialog()`