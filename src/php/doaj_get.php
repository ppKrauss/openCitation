<?php
//////////
// Abrindo o OpenLattes/DOAJ
// Ver comentários em https://gitlab.com/ciencialivre/openlattes/issues/19

print "\n---- BEGIN:DOAJ ------\n";

$DOAJ_head = [
	'Journal title'=>'jou_title',
	'Journal URL'=>'jou_url',
	'Alternative title'=>'jou_alt_title',
	'Journal ISSN (print version)'=>'issn_p',
	'Journal EISSN (online version)'=>'issn_e',
	'Publisher'=>'pub',
	'Society or institution'=>'',
	'Platform, host or aggregator'=>'plataform',
	'Country of publisher'=>'country',
	'Journal article processing charges (APCs)'=>'apcs',
	'APC information URL'=>'',
	'APC amount'=>'',
	'Currency'=>'',
	'Journal article submission fee'=>'',
	'Submission fee URL'=>'',
	'Submission fee amount'=>'',
	'Submission fee currency'=>'',
	'Number of articles publish in the last calendar year'=>'last_num_arts',
	'Number of articles information URL'=>'last_url',
	'Journal waiver policy (for developing country authors etc)'=>'',
	'Waiver policy information URL'=>'',
	'Digital archiving policy or program(s)'=>'archiv_name',
	'Archiving: national library'=>'archiv_lib',
	'Archiving: other'=>'archiv_other',
	'Archiving infomation URL'=>'archiv_url',
	'Journal full-text crawl permission'=>'',
	'Permanent article identifiers'=>'std_doi',
	'Journal provides download statistics'=>'',
	'Download statistics information URL'=>'',
	'First calendar year journal provided online Open Access content'=>'first_online',
	'Full text formats'=>'std_dtds',
	'Keywords'=>'std_keywords',
	'Full text language'=>'langs',
	'URL for the Editorial Board page'=>'',
	'Review process'=>'',
	'Review process information URL'=>'',
	"URL for journal's aims & scope"=>'',
	"URL for journal's instructions for authors"=>'',
	'Journal plagiarism screening policy'=>'',
	'Plagiarism information URL'=>'',
	'Average number of weeks between submission and publication'=>'',
	"URL for journal's Open Access statement"=>'openaccess_url',
	'Machine-readable CC licensing information embedded or displayed in articles'=>'openaccess_cc',
	'URL to an example page with embedded licensing information'=>'openaccess_url_ex',
	'Journal license'=>'jou_dft_license',
	'License attributes'=>'jou_dft_license_attribs',
	'URL for license terms'=>'jou_dft_license_url',
	'Does this journal allow unrestricted reuse in compliance with BOAI?'=>'openaccess_boai',
	'Deposit policy directory'=>'',
	'Author holds copyright without restrictions'=>'copyright_au_norestrictions',
	'Copyright information URL'=>'copyright',
	'Author holds publishing rights without restrictions'=>'copyright_au_pub_norestrictions',
	'Publishing rights information URL'=>'',
	'DOAJ Seal'=>'',
	'Tick: Accepted after March 2014'=>'',
	'Added on Date'=>'',
	'Subjects'=>'subjects'
];
$i=0;
$DOAJ_use=array();
foreach($DOAJ_head as $k=>$v) {
	if ($v) $DOAJ_use[$i]=$v;
	$i++;
}

$nmax = 0;
$n=$n_lic=0;
$SEP = ',';
$file = "/xxxx/gits/openlattes/periodicos-abertos/periodicos-do-qualis-no-doaj/input/doaj_20151125_1730_utf8.csv";
$h = fopen($file,'r');
$lic=array();
while( $h && !feof($h) && (!$nmax || $n<$nmax) ) 
	if (($lin=fgetcsv($h,0,$SEP)) && $n++>0) {
		$lin2=array();
		foreach($DOAJ_use as $k=>$v)
			$lin2[$v]=$lin[$k];
		if ($lin2['jou_dft_license']) {
			$n_lic++;
			if (isset($lic[$lin2['jou_dft_license']])) $lic[$lin2['jou_dft_license']]++;
			else $lic[$lin2['jou_dft_license']]=1;
		} //zero elseif ($lin2['copyright']) {
	}
print "Tabela DOAJ: $n revistas, $n_lic com licenças declaradas";
foreach($lic as $li=>$n_li) if ($n_li>1) {
	$perc = ((float)((int) (1000*$n_li/$n_lic)))/10.0;
	print "\n $n_li revistas com licença '$li' ($perc%)";
}
print "\n---- END:DOAJ ------\n\n";





