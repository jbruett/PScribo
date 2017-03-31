function OutMarkdown {
<#
    .SYNOPSIS
        Markdown output plugin for PScribo.
    .DESCRIPTION
        Outputs a markdown file representation of a PScribo document object.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','pluginName')]
    param (
        ## ThePScribo document object to convert to a text document
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Object] $Document,

        ## Output directory path for the .txt file
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $Path,

        ### Hashtable of all plugin supported options
        [Parameter()]
        [AllowNull()]
        [System.Collections.Hashtable] $Options
    )
    begin {

        $pluginName = 'Markdown';

    }
    process {

        $stopwatch = [Diagnostics.Stopwatch]::StartNew();
        WriteLog -Message ($localized.DocumentProcessingStarted -f $Document.Name);
        ## Create default options if not specified
        if ($null -eq $Options) { $Options = New-PScriboMarkdownOption; }

        if (-not ($Options.ContainsKey('Encoding'))) {
            $Options['Encoding'] = 'ASCII';
        }

        [System.Text.StringBuilder] $textBuilder = New-Object System.Text.StringBuilder;
        foreach ($s in $Document.Sections.GetEnumerator()) {
            if ($s.Id.Length -gt 40) { $sectionId = '{0}[..]' -f $s.Id.Substring(0,36); }
            else { $sectionId = $s.Id; }
            $currentIndentationLevel = 1;
            if ($null -ne $s.PSObject.Properties['Level']) { $currentIndentationLevel = $s.Level +1; }
            WriteLog -Message ($localized.PluginProcessingSection -f $s.Type, $sectionId) -Indent $currentIndentationLevel;
            switch ($s.Type) {
                'PScribo.Section' { [ref] $null = $textBuilder.Append((OutMarkdownSection -Section $s)); }
                'PScribo.Paragraph' { [ref] $null = $textBuilder.Append(($s | OutMarkdownParagraph)); }
                'PScribo.PageBreak' { [ref] $null = $textBuilder.AppendLine((OutMarkdownPageBreak)); }
                'PScribo.LineBreak' { [ref] $null = $textBuilder.AppendLine((OutMarkdownLineBreak)); }
                'PScribo.Table' { [ref] $null = $textBuilder.AppendLine(($s | OutMarkdownTable)); }
                'PScribo.TOC' { [ref] $null = $textBuilder.AppendLine(($s | OutMarkdownTOC)); }
                'PScribo.BlankLine' { [ref] $null = $textBuilder.AppendLine(($s | OutMarkdownBlankLine)); }
                Default { WriteLog -Message ($localized.PluginUnsupportedSection -f $s.Type) -IsWarning; }
            } #end switch
        } #end foreach
        $stopwatch.Stop();
        WriteLog -Message ($localized.DocumentProcessingCompleted -f $Document.Name);
        $destinationPath = Join-Path -Path $Path ('{0}.txt' -f $Document.Name);
        WriteLog -Message ($localized.SavingFile -f $destinationPath);
        Set-Content -Value ($textBuilder.ToString()) -Path $destinationPath -Encoding $Options.Encoding;
        [ref] $null = $textBuilder;
        WriteLog -Message ($localized.TotalProcessingTime -f $stopwatch.Elapsed.TotalSeconds);
        ## Return the file reference to the pipeline
        Write-Output (Get-Item -Path $destinationPath);

    } #end process
} #end function OutMarkdown
