$dllvar = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $dllvar -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

$token = ""
$url = "https://api.telegram.org/bot$token/"
$ChatId = ''

function Get-TelegramMessage(){
    [CmdletBinding()]
    $result = Invoke-RestMethod -Uri ($url+'getUpdates') -Body @{offset='-1';}
   
    if (($result.result.message.message_id -gt $MessageId) -and ($result.result.message.chat.id -eq $ChatId)){
        return $result.result.message
    }
}

function Get-LockedUsers(){
    [CmdletBinding()]
    $locked_users = New-Object System.Collections.Generic.List[System.Object]
    $users = Get-ADUser -Filter * -Properties LockedOut | where LockedOut -eq True
    if ($users.Length -eq 0){
    $locked_users
        return 0
    }
    foreach ($user in $users){
        $name = $user.Name
        $sid = $user.SID
        $sam = $users.samaccountname
        $locked_users.Add(@(@{name=$name; SID=$sid;}))
        }
    return $locked_users
}
function Send-TelegramMessage($Message, $ChatId){
    [CmdletBinding()]
    $form = @{
       chat_id = $ChatId;
       text = $Message;
    }
    $result = Invoke-RestMethod -Uri $($url+'sendMessage') -Body $form
    return $result    
}
function Get-TelegramMessageType($Message){
    if ($Message){
        if ($Message.text[0] -notmatch '/'){
            return $Message.message_id, 0
        }
        $text = $Message.text -replace '/',''
        if ("get_user" -eq $text){
            return $Message.message_id, 1
        }
        elseif ($text -match "^\d+$"){
            return $Message.message_id, 2, $text
        }
    }
    return 0, 1
}
while ($True){
$users0 = Get-ADUser -Filter * -Properties LockedOut | where LockedOut -eq True
   foreach ($user0 in $users0){
       $name0 = $users0.name
    }
    $response = Get-TelegramMessage
    $message_type = Get-TelegramMessageType -Message $response
    if ($message_type[0] -ne 0){
        $MessageId = $message_type[0]
    }
    if ($message_type[1] -eq 1){
        $users = Get-LockedUsers
        if (($users -ne 0) -and ($var -ne $var1)){

            $full_text = ''
            foreach ($user in $users){
                $name = $user.Name
                $name2 = $users.name
                $index = $users.indexOf($user)
                $full_text += "Unlock user $name /$index`n"
            }
            Send-TelegramMessage -Message $full_text -ChatId $ChatID
         [string]$var = $name2
         [string]$var1 = $name0
        }
        else {
      Set-Variable -Name var -Value $name0
        }
    } 
    elseif ($message_type[1] -eq 2){
        $user = $users[$message_type[2]]
        if ($user){
            $SID = $user.SID
            Unlock-AdAccount -Identity $SID
            Set-ADAccountPassword -Identity $SID -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $new_password -Force)
            Send-TelegramMessage -Message "Пользователь $($user.Name) разблокирован" -ChatId $ChatID
            Remove-Variable -Name var1 -Force -ErrorAction SilentlyContinue
        }
    }     
    sleep 5
}
