Configuration SP             
{      
    $DomainCred = Get-AutomationPSCredential -Name "DomainCredential"
    $LocalAdmin = Get-AutomationPSCredential -Name "LocalCredential"
    
        
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking -ModuleVersion 2.7.0.0
    Import-DscResource -ModuleName cChoco
    Import-DscResource –ModuleName PSDesiredStateConfiguration
           
    Node "webserver" {             
        
        WindowsFeature IIS {
            Ensure = "Present"
            Name = "Web-Server"
        }
        
        WindowsFeature ASPNET45 {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }
            
    }

    Node "sqlserver" {

    }
    
    Node "domaincontroller" {
        

    }             

    Node "chocolatey" {

        cChocoInstaller installChoco 
        { 
            InstallDir = "C:\choco" 
        }

        WindowsFeature installIIS 
        { 
            Ensure="Present" 
            Name="Web-Server" 
            IncludeAllSubFeature = $true
        }

        xFirewall WebFirewallRule 
        { 
            Direction = "Inbound" 
            Name = "Web-Server-TCP-In" 
            DisplayName = "Web Server (TCP-In)" 
            Description = "IIS allow incoming web site traffic." 
            Group = "IIS Incoming Traffic"
            Enabled = $true
            Action = "Allow"
            Protocol = "TCP" 
            LocalPort = "80" 
            Ensure = "Present" 
        }



        cChocoPackageInstaller ProGet 
        {            
            Name = "proget" 
            DependsOn = "[cChocoInstaller]installChoco","[WindowsFeature]installIIS"
        } 


 

    }
}            