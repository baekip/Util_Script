#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Result;
#############################################################
##sub
##############################################################

sub result_scatter_plot {
    my ($fh, $plot, $sample_id) = @_;
    print $fh "##$sample_id
###Profile Scatter Plot
  Plot bin-level log2 coverages and segmentation calls together. Without any further arguments, this plots the genome-wide copy number in a form familiar to those who have used array CGH.
[Download Result File](result/MC011-01_L/MC011-01_L-scatter.pdf)

\`\`\`{r scatter_plot_$sample_id, out.width = \"1000px\",out.heigh=\"800px\"}

$sample_id\_scatter_plot = \'result/$sample_id/$sample_id\_L-scatter.png\'

include_graphics($sample_id\_scatter_plot)

\`\`\`\n";
}

sub result_diagram_plot {
    my ($fh, $plot, $sample_id) = @_;
    print $fh "### Profile Diagram Plot
 Draw copy number on chromosomes as an ideogram. If both the bin-level log2 ratios and segmentation calls are given, show them side-by-side on each chromosome
[Download Result File](result/MC011-01_L/MC011-01_L-diagram.pdf) 
\`\`\`{r diagram_plot_MC011-01_L, out.width = \"1000px\",out.heigh=\"800px\"}

$sample_id\_diagram_plot = \'result/MC011-01_L/MC011-01_L-diagram.png\'

include_graphics($sample_id\_diagram_plot)

\`\`\`\n";
}

sub result_table {
    my ($fh, $sample_id) = @_;
    print $fh "### Total Result Table

 The log2 ratio value reported for each gene will be the value of the segment covering the gene. Where more than one segment overlaps the gene, i.e. if the gene contains a breakpoint, each segment's value will be reported as a separate row for the same gene.

[Download Result File](result/MC011-01_L/MC011-01_L.gene.gainloss)

\`\`\`{r table_$sample_id, results=\'asis\',echo=FALSE}
$sample_id\_cnv_result=read.table(file.path(project_path, \"\", \"result/MC011-01_L/MC011-01_L.gene.gainloss\"), header=T, sep=\"\", check.names = T)
datatable($sample_id\_cnv_result)
\`\`\`

column           Description
------------   ------------------------------------------------
chromosome      Chromosome or reference sequence name
start           Start position
gene            Gene name          
log2            Log2 mean coverage depth      
depth           Absolute-scale mean coverage depth
probes          the number of bins covered by the segment
weight          each bin's proportional weight or reliability
cn              copy number value


If log2 value is up to       Copy number
------------------------   ---------------
       -1.1                        0
       -0.4                        1
        0.3                        2
        0.7                        3
        ...                       ...
\n";
}

