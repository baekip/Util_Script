package CNV;

use Exporter qw(import);
our @EXPORT_OK=qw(cnv_target);



sub cnv_target {
    my ($id, $hash_ref) =@_;
    return $hash_ref{sample_id};
}
1;
