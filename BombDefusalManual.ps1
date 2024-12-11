[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
Add-Type -AssemblyName System.Windows.Forms

$global:activeModule = $null

function Create-Label {
    param (
        [string]$Text,
        [string]$Name,
        [int[]]$Location,
        [string]$ForeColor = "#FFFFFF",  # Default color white
        [int]$Width = 200
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Name = $Name
    $label.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $label.Width = $Width
    $label.Font = New-Object System.Drawing.Font('Courier New', 13)  # Set font size
    return $label
}

function Create-Checkbox {
    param (
        [string]$Text,
        [string]$Name,
        [int[]]$Location,
        [string]$ForeColor = "#FFFFFF",  # Default color white
        [bool]$Checked = $false
    )
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $Text
    $checkbox.Name = $Name
    $checkbox.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $checkbox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $checkbox.Checked = $Checked
    $checkbox.Width = 80
    $checkbox.Font = New-Object System.Drawing.Font('Courier New', 15)  # Set font size
    return $checkbox
}


function Create-Button {
    param (
        [string]$Text,
        [string]$Name,
        [int[]]$Location,
        [int]$Width = 105,
        [int]$Height = 70,
        [string]$BackColor = "#404040",
        [string]$ForeColor = "#FFFFFF",
        [int]$FontSize = 15
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Name = $Name
    $button.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $button.Width = $Width
    $button.Height = $Height
    $button.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $button.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $button.Font = New-Object System.Drawing.Font('Courier New', $FontSize)
    return $button
}


function Create-RadioButton {
    param (
        [string]$Text,
        [string]$Name,
        [int[]]$Location,
        [int]$Width = 120,
        [string]$ForeColor = "#FFFFFF",
        [int]$FontSize = 15
    )
    $radioButton = New-Object System.Windows.Forms.RadioButton
    $radioButton.Text = $Text
    $radioButton.Name = $Name
    $radioButton.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $radioButton.Width = $Width
    $radioButton.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $radioButton.Font = New-Object System.Drawing.Font('Courier New', $FontSize)
    return $radioButton
}

function cutWire {
    param ($wires, $oddSerial)

    $mainForm.Controls.RemoveByKey("Cut")

    $blueCount = ($wires | Where-Object { $_ -eq "BlueWire" }).Count
    $yellowCount = ($wires | Where-Object { $_ -eq "YellowWire" }).Count
    $redCount = ($wires | Where-Object { $_ -eq "RedWire" }).Count
    $whiteCount = ($wires | Where-Object { $_ -eq "WhiteWire" }).Count
    $blackCount = ($wires | Where-Object { $_ -eq "BlackWire" }).Count

    if ($wires.Count -eq 3){
        $blueCount = ($wires | Where-Object { $_ -eq "BlueWire" }).Count
        
        if (-not ($wires -contains "RedWire")){
            $cutWire = "Cut the second wire"
        }     
        elseif ($wires[2] -eq "WhiteWire"){
            $cutWire = "Cut the last wire"
        }
        elseif ($blueCount-gt 1){
            $cutWire = "Cut the last BLUE wire"
        }
        else {
            $cutWire = "Cut the last wire"
        }
    }
    
    elseif ($wires.Count -eq 4){
        
        if ($redCount -gt 1 -and $oddSerial){
            $cutWire = "Cut the last RED wire"
        }
        elseif ($wires[3] -eq "YellowWire" -and $redCount -eq 0){
            $cutWire = "Cut the first wire"
        }
        elseif ($blueCount -eq 1){
            $cutWire = "Cut the first wire"
        }
        elseif ($yellowCount -gt 1){
            $cutWire = "Cut the last wire"
        }
        else{
            $cutWire = "Cut the second wire"
        }
    }
    elseif ($wires.Count -eq 5){

        if ($wires[4] -eq "BlackWire" -and $oddSerial){
            $cutWire = "Cut the fourth wire"
        }
        elseif ($redCount -eq 1 -and $yellowCount -gt 1){
            $cutWire = "Cut the first wire"
        }
        elseif ($blackCount -eq 0){
            $cutWire = "Cut the second wire"
        }
        else{
            $cutWire = "Cut the first wire"
        }
    }
    elseif ($wires.Count -eq 6){

        if ($yellowCount -eq 0 -and $oddSerial){
            $cutWire = "Cut the third wire"
        }
        elseif ($yellowCount -eq 1 -and $whiteCount -gt 1){
            $cutWire = "Cut the fourth wire"
        }
        elseif ($redCount -eq 0){
            $cutWire = "Cut the last wire"
        }
        else {
            $cutWire = "Cut the fourth wire"
        }
    }
    else {
        $cutWire = "Did you forget your glasses today?"
    }

    $cutLabel = Create-Label -Text $cutWire -Name "Cut" -Location @(300, 350) -Width 500 -ForeColor "Green"
    $MainForm.Controls.Add($cutLabel)
}

function cleanSlate {
    $cleanWires = @("Wirelabel", "RedWireButton", "BlueWireButton", "BlackWireButton", "YellowWireButton", "WhiteWireButton", "ResetWireButton", "CutWireButton", "SerialLabel", "SerialStatusLabel", "SerialStatusButton")
    
    if ($activeModule -eq "Wires"){
        # Remove form objects
        foreach ($color in $wireColors){
            $MainForm.Controls.RemoveByKey($color)
        }

        foreach ($object in $cleanWires){
            $MainForm.Controls.RemoveByKey($object)
        }
        $MainForm.Controls.RemoveByKey("Cut")

        # Reset variables
        $global:wireColors = @()
        $global:wireCount = 0
        $wiresButton.ForeColor = "White"
    }
}

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.ClientSize = "1500, 500"
$MainForm.Text = "Bomb Hacker's Defusal Kit"
$MainForm.BackColor = "#181818"

$wiresButton = Create-Button -Text "Wires" -Name "wiresButton" -Location @(10, 10)
$MainForm.Controls.Add($wiresButton)

$buttonButton = Create-Button -Text "The Button" -Name "buttonButton" -Location @(120, 10)
$MainForm.Controls.Add($buttonButton)

$keypadsButton = Create-Button -Text "Keypads" -Name "keypadsButton" -Location @(10, 85)
$MainForm.Controls.Add($keypadsButton)

$simonButton = Create-Button -Text "Simon Says" -Name "simonButton" -Location @(120, 85)
$MainForm.Controls.Add($simonButton)

$whosOnFirstButton = Create-Button -Text "Who's on First" -Name "whosOnFirstButton" -Location @(10, 160)
$MainForm.Controls.Add($whosOnFirstButton)

$memoryButton = Create-Button -Text "Memory" -Name "memoryButton" -Location @(120, 160)
$MainForm.Controls.Add($memoryButton)

$morseButton = Create-Button -Text "Morse Code" -Name "morseButton" -Location @(10, 235)
$MainForm.Controls.Add($morseButton)

$complicatedWiresButton = Create-Button -Text "Compl. Wires" -Name "complicatedWiresButton" -Location @(120, 235)
$MainForm.Controls.Add($complicatedWiresButton)

$mazeButton = Create-Button -Text "Mazes" -Name "mazeButton" -Location @(120, 310)
$MainForm.Controls.Add($mazeButton)

$wireSequenceButton = Create-Button -Text "Wire Sequence" -Name "wireSequenceButton" -Location @(10, 310) -FontSize 13
$MainForm.Controls.Add($wireSequenceButton)

$passwordsButton = Create-Button -Text "Passwords" -Name "passwordsButton" -Location @(10, 385) -FontSize 12
$MainForm.Controls.Add($passwordsButton)

$placeholderButton = Create-Button -Text "Placeholder" -Name "placeholder" -Location @(120, 385) -FontSize 10
$MainForm.Controls.Add($placeholderButton)

$keypadsButton.Add_Click({ Write-Host "Keypads button clicked!" })
$simonButton.Add_Click({ Write-Host "Simon Says button clicked!" })
$whosOnFirstButton.Add_Click({ Write-Host "Who's on First button clicked!" })
$memoryButton.Add_Click({ Write-Host "Memory button clicked!" })
$morseButton.Add_Click({ Write-Host "Morse Code button clicked!" })
$complicatedWiresButton.Add_Click({ Write-Host "Compl. Wires button clicked!" })
$mazeButton.Add_Click({ Write-Host "Mazes button clicked!" })
$wireSequenceButton.Add_Click({ Write-Host "Wire Sequence button clicked!" })
$passwordsButton.Add_Click({ Write-Host "Passwords button clicked!" })
$placeholderButton.Add_Click({ Write-Host "Placeholder button clicked!" })


$wiresButton.Add_Click({
    $wiresButton.ForeColor = "Green"
    # Remove previously used module UI
    $global:activeModule = "Wires"
    $global:wireCount = 0
    $global:wirePos = @(100, 120, 140, 160, 180, 200)
    $global:wireColors = @()
    $global:oddSerial = $false

    $wiresLabel = Create-Label -Text "Click wire colors from top to bottom" -Name "Wirelabel" -Location @(300, 35) -Width 500
    $MainForm.Controls.Add($wiresLabel)

    $redWireButton = Create-Button -Text "Red" -Name "RedWireButton" -Location @(300, 100) -ForeColor "Red"
    $MainForm.Controls.Add($redWireButton)

    $blueWireButton = Create-Button -Text "Blue" -Name "BlueWireButton" -Location @(415, 100) -ForeColor "#37C6FF"
    $MainForm.Controls.Add($blueWireButton)

    $blackWireButton = Create-Button -Text "Black" -Name "BlackWireButton" -Location @(300, 180) -ForeColor "Black"
    $MainForm.Controls.Add($blackWireButton)

    $yellowWireButton = Create-Button -Text "Yellow" -Name "YellowWireButton" -Location @(415, 180) -ForeColor "Yellow"
    $MainForm.Controls.Add($yellowWireButton)
    
    $whiteWireButton = Create-Button -Text "White" -Name "WhiteWireButton" -Location @(300, 260)
    $MainForm.Controls.Add($whiteWireButton)

    $resetWireButton = Create-Button -Text "Reset" -Name "ResetWireButton" -Location @(300, 385)
    $MainForm.Controls.Add($resetWireButton)

    $cutWireButton = Create-Button -Text "Cut!" -Name "CutWireButton" -Location @(415, 385)
    $MainForm.Controls.Add($cutWireButton)

    $serialLabel = Create-Label -Text "Is the last serial digit odd?" -Name "SerialLabel" -Location @(550, 265) -Width 500
    $MainForm.Controls.Add($serialLabel)
    
    $serialLabel = Create-Label -Text "No" -Name "SerialStatusLabel" -Location @(550, 290) -Width 50
    $MainForm.Controls.Add($serialLabel)

    $serialStatusButton = Create-Button -Text "Change" -Name "SerialStatusButton" -Location @(600, 290) -Height 25
    $MainForm.Controls.Add($serialStatusButton)


    $redWireButton.Add_Click({
        if ($wireCount -lt 6){
            $r = Create-Label -Text "Red" -Name "RedWire" -Location @(600, $wirePos[$wireCount]) -Width 150 -ForeColor "Red"
            $MainForm.Controls.Add($r)
            $global:wireColors += ("RedWire")
            $global:wireCount ++
        }
    })

    $blueWireButton.Add_Click({
        if ($wireCount -lt 6){
            $b = Create-Label -Text "Blue" -Name "BlueWire" -Location @(600, $wirePos[$wireCount]) -Width 150 -ForeColor "#37C6FF"
            $MainForm.Controls.Add($b)
            $global:wireColors += ("BlueWire")
            $global:wireCount ++
        }
    })

    $blackWireButton.Add_Click({
        if ($wireCount -lt 6){
            $k = Create-Label -Text "Black" -Name "BlackWire" -Location @(600, $wirePos[$wireCount]) -Width 150 -ForeColor "#808080"
            $MainForm.Controls.Add($k)
            $global:wireColors += ("BlackWire")
            $global:wireCount ++
        }
    })

    $yellowWireButton.Add_Click({
        if ($wireCount -lt 6){
            $y = Create-Label -Text "Yellow" -Name "YellowWire" -Location @(600, $wirePos[$wireCount]) -Width 150 -ForeColor "Yellow"
            $MainForm.Controls.Add($y)
            $global:wireColors += ("YellowWire")
            $global:wireCount ++
        }
    })

    $whiteWireButton.Add_Click({
        if ($wireCount -lt 6){
            $w = Create-Label -Text "White" -Name "WhiteWire" -Location @(600, $wirePos[$wireCount]) -Width 150
            $MainForm.Controls.Add($w)
            $global:wireColors += ("WhiteWire")
            $global:wireCount ++
        }
    })

    $resetWireButton.Add_Click({
        foreach($color in $wireColors){
            $MainForm.Controls.RemoveByKey($color)
            $MainForm.Controls.RemoveByKey("Cut")
        }
        $global:wireColors = @()
        $global:wireCount = 0
    })

    $cutWireButton.Add_Click({
        cutWire $wireColors $oddSerial
    })

    $serialStatusButton.Add_Click({
        $MainForm.Controls.RemoveByKey("SerialStatusLabel")
        if ($global:oddSerial -eq $false){
            $global:oddSerial = $true
            $serialLabel = Create-Label -Text "Yes" -Name "SerialStatusLabel" -Location @(550, 290) -Width 50
            $MainForm.Controls.Add($serialLabel)
        }
        else {
            $global:oddSerial = $false
            $serialLabel = Create-Label -Text "No" -Name "SerialStatusLabel" -Location @(550, 290) -Width 50
            $MainForm.Controls.Add($serialLabel)
        } 
    })
}) # TODO # Remove previously used module

$buttonButton.Add_Click({
    cleanSlate
    # Remove previousely used module
    $global:activeModule = "Button"
    $global:buttonColor = $null
    $global:buttonText = $null
    $buttonButton.ForeColor = "Green"
    
    
    $buttonColorLabel = Create-Label -Text "Color of button:" -Name "ButtonColorLabel" -Location @(300, 35) -Width 200
    $MainForm.Controls.Add($buttonColorLabel)

    $redButtonButton = Create-Button -Text "Red" -Name "RedButtonButton" -Location @(300, 75) -BackColor "Red"
    $MainForm.Controls.Add($redButtonButton)

    $blueButtonButton = Create-Button -Text "Blue" -Name "BlueButtonButton" -Location @(415, 75) -BackColor "#37C6FF"
    $MainForm.Controls.Add($blueButtonButton)

    $blackButtonButton = Create-Button -Text "Black" -Name "BlackButtonButton" -Location @(530, 75) -BackColor "#808080"
    $MainForm.Controls.Add($blackButtonButton)

    $yellowButtonButton = Create-Button -Text "Yellow" -Name "YellowButtonButton" -Location @(645, 75) -BackColor "#DFBC20"
    $MainForm.Controls.Add($yellowButtonButton)

    $whiteButtonButton = Create-Button -Text "White" -Name "WhiteButtonButton" -Location @(760, 75) -BackColor "#FFFFFF" -ForeColor "Black"
    $MainForm.Controls.Add($whiteButtonButton)

    $buttonTextLabel = Create-Label -Text "Text on button:" -Name "ButtonTextLabel" -Location @(300, 180) -Width 200
    $MainForm.Controls.Add($buttonTextLabel)

    $holdButtonButton = Create-Button -Text "Hold" -Name "HoldButtonButton" -Location @(300, 220)
    $MainForm.Controls.Add($holdButtonButton)

    $holdButtonButton = Create-Button -Text "Press" -Name "PressButtonButton" -Location @(415, 220)
    $MainForm.Controls.Add($holdButtonButton)

    $holdButtonButton = Create-Button -Text "Abort" -Name "AbortButtonButton" -Location @(530, 220)
    $MainForm.Controls.Add($holdButtonButton)

    $holdButtonButton = Create-Button -Text "Detonate" -Name "DetonateButtonButton" -Location @(645, 220) -FontSize 13
    $MainForm.Controls.Add($holdButtonButton)

    $exampleLabel = Create-Label -Text "Click when ready" -Name "ButtonTextLabel" -Location @(870, 275) -Width 200
    $MainForm.Controls.Add($exampleLabel)

    $exampleButton = Create-Button -Text "Example" -Name "ExampleButton" -Location @(900, 300) -FontSize 13 -BackColor "Pink" -ForeColor "Black"
    $MainForm.Controls.Add($exampleButton)

 })

[void]$MainForm.ShowDialog()
