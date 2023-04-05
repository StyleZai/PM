*** Settings ***
Documentation                                           Template robot main suite.
#Orders robots from RobotSpareBin Industries Inc.
...                                                     Saves the order HTML receipt as a PDF file.
...                                                     Saves the screenshot of the ordered robot.
...                                                     Embeds the screenshot of the robot to the PDF receipt.
...                                                     Creates ZIP archive of the receipts and the images.

Library                                                 RPA.Browser.Selenium    auto_close=${FALSE}
Library                                                 RPA.HTTP
Library                                                 RPA.Excel.Files
Library                                                 RPA.Tables
Library                                                 RPA.PDF
Library                                                 RPA.Desktop
Library                                                 RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download Excel Order File
    ${Orders}=    Read CSV File and Return Value
    Looping    ${Orders}
    #Delete png    ${Orders}
    #Delete CSV
    Zip Folder


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    xpath://button[contains(text(),'OK')]

Download Excel Order File
    Download
    ...    https://robotsparebinindustries.com/orders.csv
    ...    target_file=${OUTPUT DIR}${/}Downloads${/}orders.csv
    ...    overwrite=True

Read CSV File and Return Value
    ${Orders}=    Read table from CSV    ${OUTPUT DIR}${/}Downloads${/}orders.csv    header=True
    RETURN    ${Orders}

Looping
    [Arguments]    ${Orders}
    FOR    ${Order}    IN    @{Orders}
        # Fill and submit the form for one person    ${sales_rep}
        Fill in the website    ${Order}
        # Log    ${Order}
    END

Fill in the website
    [Arguments]    ${Order}
    # Select From List By Value    head    ${Order}[Head]
    # Input Text    body    ${Order}[Body]
    # Input Text    number    ${Order}[Legs]
    # Input Text    address    ${Order}[Address]
    Close the annoying modal
    Select From List By Value    head    ${Order}[Head]
    Input Text    xpath://input[contains(@placeholder,'Enter the part number for the legs')]    ${Order}[Legs]
    Select Radio Button    body    ${Order}[Body]
    Input Text    address    ${Order}[Address]
    Click Button    xpath://button[contains(text(),'Preview')]
    Wait Until Keyword Succeeds    10x    3s    Click Order Button
    #Wait Until Page contains    Order another robot
    Store Receipt as PDF    ${Order}
    Click Button    xpath://button[contains(text(),'Order another robot')]

Click Order Button
    Click Button    xpath://button[contains(text(),'Order')]
    Wait Until Element Is Visible    id:receipt
    # Select From List By Value    head    2
    # Input Text    address    Address 123
    # Input Text    xpath://input[contains(@placeholder,'Enter the part number for the legs')]    1
    # Select Radio Button    body    1
    # Click Button    xpath://button[contains(text(),'Preview')]
    # Click Button    xpath://button[contains(text(),'Order')]

    # $(Contents) =
    # Return from $(Contents)

Store Receipt as PDF
    [Arguments]    ${Order}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}Downloads${/}Receipt${Order}[Order number].pdf
    Screenshot
    ...    xpath://div[@id='robot-preview-image']
    ...    ${OUTPUT_DIR}${/}Downloads${/}Preview${Order}[Order number].png
    Embbed The Robot Screenshot To Receipt PDF File    ${Order}

Embbed The Robot Screenshot To Receipt PDF File
    [Arguments]    ${Order}
    Open Pdf    ${OUTPUT_DIR}${/}Downloads${/}Receipt${Order}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}Downloads${/}Preview${Order}[Order number].png
    ...    ${OUTPUT_DIR}${/}Downloads${/}Receipt${Order}[Order number].pdf
    Close Pdf

Delete png    [Arguments]    ${Order}
    ${Orders}
    FOR    ${Order}    IN    @{Order}
        Delete    ${OUTPUT_DIR}${/}Downloads${/}Preview${Order}[Order number].png
    END

Zip Folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Downloads    PM_Robot.zip

Delete CSV
    Delete    ${OUTPUT_DIR}${/}Downloads${/}orders.csv
# read table from CSV

    # FOR    ${Order number}    IN    @{Order number}
    #    Fill and submit the form for one person    ${sales_rep}
    # END
