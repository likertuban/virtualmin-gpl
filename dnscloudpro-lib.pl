# Cloudflare DNS provider shim for Virtualmin GPL via list_pro_dns_clouds

BEGIN { push(@INC, ".."); }
use WebminCore;
&init_config();

our $dnscloud_cloudflare_loaded;
return 1 if ($dnscloud_cloudflare_loaded);
$dnscloud_cloudflare_loaded = 1;

sub load_cloudflare_sync_module
{
return $main::cloudflare_sync_loaded if (defined($main::cloudflare_sync_loaded));
$main::cloudflare_sync_loaded = 0;
if (defined(&foreign_installed) &&
    &foreign_installed('virtualmin-cf-sync')) {
    eval {
        &foreign_require('virtualmin-cf-sync',
                         'virtualmin-cf-sync-lib.pl');
        $main::cloudflare_sync_loaded = 1;
    };
}
return $main::cloudflare_sync_loaded;
}

sub cloudflare_missing_text
{
return $text{'dnscloud_cf_missing'}
       || 'Install and configure the Cloudflare DNS Sync plugin.';
}

sub cf_get_function
{
my ($func) = @_;
no strict 'refs';
my $fq = "virtualmin_cf_sync::$func";
if (defined(&$fq)) {
    return \&{$fq};
}
elsif (defined(&$func)) {
    return \&{$func};
}
return undef;
}

sub cf_call_scalar
{
my ($func, @args) = @_;
return cloudflare_missing_text() if (!load_cloudflare_sync_module());
my $code = &cf_get_function($func);
return "Missing Cloudflare handler $func" if (!$code);
return &$code(@args);
}

sub cf_call_list
{
my ($func, @args) = @_;
return (0, cloudflare_missing_text()) if (!load_cloudflare_sync_module());
my $code = &cf_get_function($func);
return (0, "Missing Cloudflare handler $func") if (!$code);
return &$code(@args);
}

sub list_pro_dns_clouds
{
return () if (!load_cloudflare_sync_module());
return ({
    'name'     => 'cloudflare',
    'desc'     => $text{'dnscloud_cf_desc'} || 'Cloudflare DNS',
    'comments' => 0,
    'defttl'   => 1,
    'proxy'    => 1,
    'disable'  => 0,
    'import'   => 0,
    'url'      => 'https://www.cloudflare.com/dns/',
    'longdesc' => $text{'dnscloud_cf_longdesc'}
                  || 'Manage DNS zones via the Cloudflare API.',
});
}

sub dnscloud_cloudflare_check        { cf_call_scalar('dnscloud_cloudflare_check', @_); }
sub dnscloud_cloudflare_get_state    { cf_call_scalar('dnscloud_cloudflare_get_state', @_); }
sub dnscloud_cloudflare_test         { cf_call_scalar('dnscloud_cloudflare_test', @_); }
sub dnscloud_cloudflare_show_inputs  { cf_call_scalar('dnscloud_cloudflare_show_inputs', @_); }
sub dnscloud_cloudflare_parse_inputs { cf_call_scalar('dnscloud_cloudflare_parse_inputs', @_); }
sub dnscloud_cloudflare_clear        { cf_call_scalar('dnscloud_cloudflare_clear', @_); }
sub dnscloud_cloudflare_create_domain{ cf_call_list('dnscloud_cloudflare_create_domain', @_); }
sub dnscloud_cloudflare_delete_domain{ cf_call_list('dnscloud_cloudflare_delete_domain', @_); }
sub dnscloud_cloudflare_put_records  { cf_call_list('dnscloud_cloudflare_put_records', @_); }
sub dnscloud_cloudflare_get_records  { cf_call_list('dnscloud_cloudflare_get_records', @_); }
sub dnscloud_cloudflare_get_nameservers { cf_call_list('dnscloud_cloudflare_get_nameservers', @_); }
sub dnscloud_cloudflare_check_domain { cf_call_scalar('dnscloud_cloudflare_check_domain', @_); }
sub dnscloud_cloudflare_valid_domain { cf_call_scalar('dnscloud_cloudflare_valid_domain', @_); }
sub dnscloud_cloudflare_rename_domain{ cf_call_list('dnscloud_cloudflare_rename_domain', @_); }
sub dnscloud_cloudflare_disable_domain{ cf_call_list('dnscloud_cloudflare_disable_domain', @_); }
sub dnscloud_cloudflare_enable_domain{ cf_call_list('dnscloud_cloudflare_enable_domain', @_); }

1;
