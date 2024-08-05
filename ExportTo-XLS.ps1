<#
.SYNOPSIS
    Export a Hash table to a spreadsheet with a seperate tab for each list in the hash table

.DESCRIPTION
    Export a Hash table to a spreadsheet with a seperate tab for each list in the hash table

.NOTES
    Author: Brian W Fruehling
    Version: 1.0
    License: GPL
    Date Written: Aug-2024

.INPUTS
    hashtable of lists or just a list for a single tab spreadsheet

.OUTPUTS
    spreadsheet in the specified output dir

.EXAMPLE
    $hashtable | ExportTo-XLS -Path $filepath.xlsx

    export the hashtable to a spreadsheet
#>

# Requires -Modules @{ ModuleName="ImportExcel"; ModuleVersion="7.8.9"} 
# require excel
Function ExportTo-XLS {
  [CmdletBinding()]
    Param(
        #<parameter comment>
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [psobject[]]$inputObject,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        [string]$path
    ) 
    begin { 
      $inputTable=@{}
      $inputtable.objects=@()
      #create xls
      $excel = New-Object -ComObject "Excel.Application"
      $excel.visible = $true
      $excelWinHwnd = $excel.Hwnd
      $process = Get-Process Excel | Where-Object {$_.MainWindowHandle -eq $excelWinHwnd}
      $excelProcessId = $process.Id
      $excel.Visible = $false
      $workbook = $excel.workbooks.Add()
      $workbook.SaveAs($path)
    }

    process {
      #if no keys add create a new hashtable and add inputobject to it. otherwise, set the new hashtable equal to the inputobect
      if(-not($inputObject.keys)) { $inputtable.objects+=$inputobject } 
      else {$inputTable = $inputObject}
    } 

    end {
      foreach ($tab in $InputTable.Keys) {
        #add tab to xls
        $worksheet=$workbook.worksheets.add()
        $worksheet.Name = $tab
        #write header row
        $fields = $InputTable.$tab[0].psobject.properties
        $col=0
        foreach ($field in $fields) {
          $row = 1
          ++$col 
          $worksheet.Cells.Item($row,$col) = $field.Name
        }
        $workbook.Save()
        foreach ($obj in $InputTable.$tab) {
          $row = $InputTable.$tab.IndexOf($obj)+2
          foreach ($prop in $obj.psobject.properties) {
            #find col in row one that matches prop name
            $col = $worksheet.rows(1).Find($prop.Name).Column
            if ($prop.TypeNameOfValue -match 'System.Collections.Generic.List') { $value = $prop.Value -join "," }
            else { $value = $prop.Value }
            $worksheet.Cells.Item($row,$col) = $Value
          }
        }
        #adjusting the column width so all data’s properly visible
        $usedRange = $worksheet.UsedRange
        $usedRange.EntireColumn.AutoFit() | Out-Null
        $workbook.Save()
      }
      #find and delete empty sheets, loop through each sheet check for no used range
      for ($sheet=1; $sheet -le $workbook.sheets.count();++$sheet) {
        if($workbook.sheets.item($sheet).UsedRange.rows.count -le 1) { $workbook.sheets.item($sheet).delete() }
      }
      $workbook.Save()
      $excel.Quit()
      Stop-Process -iD $excelProcessId
  }
}