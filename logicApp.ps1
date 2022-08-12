Write-Host('You need the Azure CLI to run this script.')
#To Deploy the Logic App to Azure, Azure CLI is needed, will need to sign in with the admin account
#For the Account wanting to deploy to

$regionName = "centralus"
#Region for the Logic App, defaults to Central US, assign here to change it
function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

if (Check-Command -cmdname 'az') {
    Write-Host "Azure CLI is found..."
}
else {
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    az extension add --name logic
    Write-Host "Please run 'az-login' and re-execute this script"
    return
}
#Checks for Azure Cli Command, if found, continues with script like normal, if not, invokes a curl request to Microsoft's servers
#Automatically adds the CLI if not found
#Run az-login to login to the admin account

$schema = "$" + "schema"
$connections = "$" + "connections"
#Variables needed for JSON formatting

$output = az account show -o json | ConvertFrom-Json
$subscriptionList = az account list -o json | ConvertFrom-Json 
$subscriptionName = $output.name
$subscriptionList | Format-Table name, id, tenantId, user -AutoSize
$accountID = $output.id
#Pulls the account Subscription, needed for communicating with Azure

Write-Host "Currently logged in to email" $output.user
#Shows the current admin account logged in with

$rndNumber = Get-Random -Minimum 100 -Maximum 999
$rsgName = "bsgLogicAutomation$rndNumber"
#Pulls Variable for Resource Group name, needed for Deploying to Azure, generates random number to attach to the end for uniqueness of name
#To change to a pre-determined resource group name, assign it here manually instead

$rsgExists = az group exists -n $rsgName
if ($rsgExists -eq 'false') {
    Write-Host "Creating Resource Group" -ForegroundColor Cyan
    $echo = az group create -l $regionName -n $rsgName
}
#Checks for resource group - if does not currently exist, generates it.

$nameOfApp = Read-Host -Prompt "Enter Name for this LogicApp"
#Name of the Logic App desired

$workFlow = '"workflows_'+$nameOfApp+'_name"'
$id = "/subscriptions/"+$accountID+"/resourceGroups/"+$rsgName+"/providers/Microsoft.Logic/workflows/"+$nameOfApp
$office365ID = "/subscriptions/"+$accountID+"/providers/Microsoft.Web/locations/centralus/managedApis/office365"
$office365Connector = "/subscriptions/"+$accountID+"/resourceGroups/LogicFlow/providers/Microsoft.Web/connections/office365"
$sharePointID = "/subscriptions/"+$accountID+"/providers/Microsoft.Web/locations/centralus/managedApis/sharepointonline"
$sharePointConnector = "/subscriptions/"+$accountID+"/resourceGroups/LogicFlow/providers/Microsoft.Web/connections/sharepointonline"
#Variables needed for JSON file for Azure Deployment, needs the API connectors with subscription name
#Pulls these automatically after being logged in with the apprioriate admin account

$emailsToParse = Read-Host -Prompt "Enter Emails, followed by spaces, you want this flow to trigger based off (if from who, parse the attachement)"
$emailSenders = $emailsToParse.Replace(" ", "; ")
#When parsing the emails, it can be assigned from who (if Mschuler, sends the email, I want the attachements to be uploaded)
#Leave blank for every email to be parsed

$sharedMailboxInput = Read-Host -Prompt ('Please enter the address of the shared mailbox E.G samples@vivifycompany.com')
#Shared mailbox to parse. May need to login to azure.portal.com and click the logic app to authenticate access.
function Get-Company
{
$selection=Read-Host "Choose a Company Sharepoint A. Vivify B. GAM C. FisherCohen D. BSG E. Nationwide Insurance F. Twin Orchard "
Switch ($selection)
{
A {$ChosenCompany="https://vivifycompany.sharepoint.com/sites/SandreamSpecialties-CompanyFiles"}
B {$ChosenCompany="https://gamweb.sharepoint.com"}
C {$ChosenCompany="https://fishercohen.sharepoint.com"}
D {$ChosenCompany="https://bsgtech.sharepoint.com"}
E {$ChosenCompany="https://netorg6441441.sharepoint.com/sites/jeffvuk.com"}
F {$ChosenCompany="https://twinorchardcountryclub.sharepoint.com/sites/AllCompany.2540761.yfttmfjb"}
}
if ($ChosenCompany -eq $null){
    Write-Host('Please Enter a valid Choice (A, B, C, D, E, F)') -Fore red
}
else {
return $ChosenCompany
}
}
$company = Get-Company
#Gets company sharepoint location. Hard to pull automatically, as there are different sites within a single company
#Some of these sites the admin accounts have access to, some they do not, so it is hard coded for ones that will work
#Each site has a shared documents folder with a 'ReportingTest' folder, uploads the documents there

$workflowJson = @"
{
    "accessControl": null,
    "accessEndpoint": "https://prod-10.centralus.logic.azure.com:443/workflows/f0e11185839346199ae6876af9cf1f2e",
    "changedTime": "2022-07-28T22:10:29.676517+00:00",
    "createdTime": "2022-07-28T22:00:34.271018+00:00",
    "definition": {
      "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
      "actions": {
        "Delete_email_(V2)": {
          "inputs": {
            "host": {
              "connection": {
                "name": "@parameters('$connections')['office365']['connectionId']"
              }
            },
            "method": "delete",
            "path": "/codeless/v1.0/me/messages/@{encodeURIComponent(triggerBody()?['id'])}"
          },
          "runAfter": {
            "For_each": [
              "Succeeded"
            ]
          },
          "type": "ApiConnection"
        },
        "For_each": {
          "actions": {
            "Create_file": {
              "inputs": {
                "body": "@items('For_each')",
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['sharepointonline']['connectionId']"
                  }
                },
                "method": "post",
                "path": "/datasets/@{encodeURIComponent(encodeURIComponent('$company'))}/files",
                "queries": {
                  "folderPath": "/Shared Documents/ReportingTest",
                  "name": "@triggerBody()?['subject']",
                  "queryParametersSingleEncoded": true
                }
              },
              "runAfter": {},
              "runtimeConfiguration": {
                "contentTransfer": {
                  "transferMode": "Chunked"
                }
              },
              "type": "ApiConnection"
            }
          },
          "foreach": "@triggerBody()?['attachments']",
          "runAfter": {},
          "type": "Foreach"
        }
      },
      "contentVersion": "1.0.0.0",
      "outputs": {},
      "parameters": {
        "$connections": {
          "defaultValue": {},
          "type": "Object"
        }
      },
      "triggers": {
        "When_a_new_email_arrives_in_a_shared_mailbox_(V2)": {
          "evaluatedRecurrence": {
            "frequency": "Minute",
            "interval": 3
          },
          "inputs": {
            "host": {
              "connection": {
                "name": "@parameters('$connections')['office365']['connectionId']"
              }
            },
            "method": "get",
            "path": "/v2/SharedMailbox/Mail/OnNewEmail",
            "queries": {
              "folderId": "Inbox",
              "from": "$emailSenders",
              "hasAttachments": false,
              "importance": "Any",
              "includeAttachments": false,
              "mailboxAddress": "$sharedMailboxInput"
            }
          },
          "recurrence": {
            "frequency": "Minute",
            "interval": 3
          },
          "splitOn": "@triggerBody()?['value']",
          "type": "ApiConnection"
        }
      }
    },
    "endpointsConfiguration": {
      "connector": {
        "accessEndpointIpAddresses": null,
        "outgoingIpAddresses": [
          {
            "address": "52.173.241.27"
          },
          {
            "address": "52.173.245.164"
          },
          {
            "address": "13.89.171.80/28"
          },
          {
            "address": "13.89.178.64/27"
          },
          {
            "address": "40.77.68.110"
          },
          {
            "address": "20.98.144.224/27"
          },
          {
            "address": "20.98.145.0/28"
          },
          {
            "address": "20.80.123.134"
          },
          {
            "address": "20.80.123.57"
          }
        ]
      },
      "workflow": {
        "accessEndpointIpAddresses": [
          {
            "address": "13.67.236.76"
          },
          {
            "address": "40.77.111.254"
          },
          {
            "address": "40.77.31.87"
          },
          {
            "address": "104.43.243.39"
          },
          {
            "address": "13.86.98.126"
          },
          {
            "address": "20.109.202.37"
          }
        ],
        "outgoingIpAddresses": [
          {
            "address": "13.67.236.125"
          },
          {
            "address": "104.208.25.27"
          },
          {
            "address": "40.122.170.198"
          },
          {
            "address": "40.113.218.230"
          },
          {
            "address": "23.100.86.139"
          },
          {
            "address": "23.100.87.24"
          },
          {
            "address": "23.100.87.56"
          },
          {
            "address": "23.100.82.16"
          },
          {
            "address": "52.141.221.6"
          },
          {
            "address": "52.141.218.55"
          },
          {
            "address": "20.109.202.36"
          },
          {
            "address": "20.109.202.29"
          }
        ]
      }
    },
    "id": "$id",
    "integrationAccount": null,
    "integrationServiceEnvironment": null,
    "location": "$regionName",
    "name": "$nameOfApp",
    "parameters": {
      "$connections": {
        "description": null,
        "metadata": null,
        "type": null,
        "value": {
          "office365": {
            "connectionId": "$office365Connector",
            "connectionName": "office365",
            "id": "$office365ID"
          },
          "sharepointonline": {
            "connectionId": "$sharePointConnector",
            "connectionName": "sharepointonline",
            "id": "$sharePointID"
          }
        }
      }
    },
    "provisioningState": "Succeeded",
    "resourceGroup": "$rsgName",
    "sku": null,
    "state": "Disabled",
    "tags": null,
    "type": "Microsoft.Logic/workflows",
    "version": "08585425606558093852"
  }
"@

Write-Output $workflowJson > workflow.json
Write-Host("The Code for your LogicApp has been written to the logic.json file in your current Directory!")
#This is the Logic App Template! This is what deploys it. Each variable pulled from before will be placed into this JSON variable
#With the Variables inserted, it will automatically make the connectors and API connections, like Sharepoint and Outlook
#Writes it to a local file, may review if wanting to change any variables or for local record.

Write-Host "Now Preparing to Deploy ..." -ForegroundColor Blue
Write-Output $formattedWorlflowJson > formattedflow.json
$checkForLogicApp = az logic workflow list --query "[?name=='$nameOfApp']" | ConvertFrom-Json
$logicAppExists = $checkForLogicApp -gt 0
if (!$logicAppExists) {
    Write-Host("Deploying Your Logic app") -ForegroundColor Green
    $echo = az logic workflow create --resource-group $rsgName --location $regionName --name $nameOfApp --definition .\workflow.json
}
#Checks if exists, if does not, creates it with the JSON file made from the previous step. It will be available to view in the azure portal shortly
#If wanting to check it from the CLI, use ## az logic workflow show
