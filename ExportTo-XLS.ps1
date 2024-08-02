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

    export the hashtable to a spreadshee
#>

# Requires -Modules @{ ModuleName="ImportExcel"; ModuleVersion="7.8.9"} 
Function ExportTo-XLS {
  [CmdletBinding()]
    Param(
        #<parameter comment>
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        [hashtable]$InputObject,
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        [string]$Path
    ) 
    
    #create xls based on path
    $excel = New-Object -ComObject excel.application
    $workbook = $excel.workbooks.Add()
    foreach ($tab in $InputObject.Keys) {
      #add tab to xls, try to autofit col if possible
      $worksheet=$workbook.worksheets.add()
      $worksheet.Name = $tab
      #write header
      $fields = $InputObject.$tab[0].psobject.properties
      $col=0
      foreach ($field in $fields) {
        $row = 1
        ++$col 
        $worksheet.Cells.Item($row,$col) = $field.Name
      }
      foreach ($obj in $InputObject.$tab) {
        $row = $InputObject.$tab.IndexOf($obj)+2
        foreach ($prop in $obj.psobject.properties) {
          #find col in row one that matches prop name
          $col = $worksheet.rows(1).Find($prop.Name).Column
          if ($prop.TypeNameOfValue -match 'System.Collections.Generic.List') { $value = $prop.Value -join "," }
          else { $value = $prop.Value }
          $worksheet.Cells.Item($row,$col) = $Value
        }
        #adjusting the column width so all data’s properly visible
        $usedRange = $worksheet.UsedRange
        $usedRange.EntireColumn.AutoFit() | Out-Null
      }
    }
    #not working
    $workbook.worksheets.Item(1).Delete()
    $workbook.SaveAs($path)
    $workbook.Save()
    #not working?
    $excel.Quit()
}