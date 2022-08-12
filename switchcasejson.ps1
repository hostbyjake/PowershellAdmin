$sharePointSite = 'https://vivifycompany.sharepoint.com/sites/SandreamSpecialties-CompanyFiles'
$pathToExcel = 'C:\Users\jjones\Scripts\LogicAppVivify.xlsx'

#Install-module PSExcel -Force
Import-module psexcel 
$people = new-object System.Collections.ArrayList

foreach ($person in (Import-XLSX -Path $pathToExcel -RowStart 1)) {
    $people.add($person) | out-null 
}

$schema = "$" + "schema"
$connections = "$" + "connections"

$emailsToParse = $people.FROM | Select-Object -unique
$locationToSend = $people.FOLDER | Select-Object -unique

for ($i = 1; $i -lt $emailsToParse.Count; $i++) {
    $forEachNumber = $i 
    $caseNumber = $forEachNumber -1
    $createFileNumber = $forEachNumber
    $folderPath = $locationToSend[$i]
    $senderToParse = $emailsToParse[$i]
    $EchoedStatement = 'If from ' + $senderToParse + ' going to ' + $folderPath
    Write-Output $EchoedStatement
    
    $Case = @"
    "Case_$caseNumber": {
    "actions": {
        "For_each_$forEachNumber": {
            "actions": {
                "Create_file_$createFileNumber": {
                    "inputs": {
                        "body": "@items('For_each_$forEachNumber')",
                        "host": {
                            "connection": {
                                "name": "@parameters('$connections')['sharepointonline']['connectionId']"
                            }
                        },
                        "method": "post",
                        "path": "/datasets/@{encodeURIComponent(encodeURIComponent('$sharePointSite'))}/files",
                        "queries": {
                            "folderPath": "/$folderPath",
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
    "case": "$senderToParse"
},
"@
$CaseList += ($Case)
Write-Output $Case
}
$lastCaseEmailToParse = $emailsToParse[0]
$lastCaseFolder = $locationToSend[0]
$lastCaseNumber = $emailsToParse.Count
$lastCaseIdentifier = $LastCaseNumber -1
$lastCase = @"
"Case_$lastCaseIdentifier": {
    "actions": {
        "For_each_$lastCaseNumber": {
            "actions": {
                "Create_file_$lastCaseNumber": {
                    "inputs": {
                        "body": "@items('For_each_$lastCaseNumber')",
                        "host": {
                            "connection": {
                                "name": "@parameters('$connections')['sharepointonline']['connectionId']"
                            }
                        },
                        "method": "post",
                        "path": "/datasets/@{encodeURIComponent(encodeURIComponent('$sharePointSite'))}/files",
                        "queries": {
                            "folderPath": "/$lastCaseFolder",
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
    "case": "$lastCaseEmailToParse"
}
"@

$workflowJson = @"
{
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
                    "Switch": [
                        "Succeeded"
                    ]
                },
                "type": "ApiConnection"
            },
            "Switch": {
                "cases": {
                    $CaseList
                    $lastCase
                },
                "default": {
                    "actions": {
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
                                        "path": "/datasets/@{encodeURIComponent(encodeURIComponent('$sharePointSite'))}/files",
                                        "queries": {
                                            "folderPath": "/Reporting",
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
                    }
                },
                "expression": "@triggerBody()?['from']",
                "runAfter": {},
                "type": "Switch"
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
                        "from": "jjones@bsgtech.com",
                        "hasAttachments": false,
                        "importance": "Any",
                        "includeAttachments": false,
                        "mailboxAddress": "samples@vivifycompany.com"
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
    "parameters": {
        "$connections": {
            "value": {
                "office365": {
                    "connectionId": "/subscriptions/7be458ed-9d5e-4b79-bedb-b61e8510e45b/resourceGroups/LogicFlow/providers/Microsoft.Web/connections/office365",
                    "connectionName": "office365",
                    "id": "/subscriptions/7be458ed-9d5e-4b79-bedb-b61e8510e45b/providers/Microsoft.Web/locations/centralus/managedApis/office365"
                },
                "sharepointonline": {
                    "connectionId": "/subscriptions/7be458ed-9d5e-4b79-bedb-b61e8510e45b/resourceGroups/LogicFlow/providers/Microsoft.Web/connections/sharepointonline",
                    "connectionName": "sharepointonline",
                    "id": "/subscriptions/7be458ed-9d5e-4b79-bedb-b61e8510e45b/providers/Microsoft.Web/locations/centralus/managedApis/sharepointonline"
                }
            }
        }
    }
}
"@

Write-Output $workflowJson > .\workflowSwitch.json