<?php
/**
 * Scan e carga para banco SQL, dos XMLs dispostos em filesystem. Ver scripts "ini.sql".
 */

// // // //
// CONFIGURACOES:
$PG_USER = 'postgres';
$PG_PW   = 'xxx'; 
$pasta =  '/xxx/openCoherence/data';


$n=0;
$dsn="pgsql:dbname=postgres;host=localhost";
$db = new pdo($dsn,$PG_USER,$PG_PW);

$XHEAD = ''; // $XHEAD = '<?xml version="1.0" encoding="UTF-8"  >'."\n";
$rgx_doctype = '/\s*<!DOCTYPE\s([^>]+)>/s';  // needs ^

$stmt = $db->prepare('DELETE FROM oc.docs'); $stmt->execute();
$stmt = $db->prepare('DELETE FROM oc.repositories'); $stmt->execute();

$stmt = $db->prepare(
  "	INSERT INTO oc.repositories(repo_label,repo_name,repo_url,repo_wikidataID,repo_info) 
	VALUES (:label,:name,:url,:wikidataID,:info)
  "
); 

// // // // // // // // // // // //
// //  BEGIN:CARGA lawRepos

$SEP = ',';
$nmax = 0;   // 100 or 0
$FILES = [
	'sciRepos.csv'=>array('repo-wikidataID-rel','url-dft-lincense'),
	'lawRepos.csv'=>array('repo-wikidataID-rel','country','legalSys','BerneConv','dft-license','legis-wikidataID','legis-wikidataID-rel','docs-lang')
];
foreach($FILES as $f=>$items) {
	$h = fopen("$pasta/$f",'r');
	$n=$n2=0;
	while( $h && !feof($h) && (!$nmax || $n<$nmax) ) if (($lin0=$lin = fgetcsv($h,0,$SEP)) && $n++>0) {
		; // 0 ou max. length por performance
		$stmt->bindParam(':label', array_shift($lin),PDO::PARAM_STR);
		$stmt->bindParam(':name',  array_shift($lin),PDO::PARAM_STR);
		$stmt->bindParam(':wikidataID',array_shift($lin),PDO::PARAM_STR);
		$stmt->bindParam(':url',   array_shift($lin),PDO::PARAM_STR);
		$info = json_encode( array_combine($items,$lin) );
		$stmt->bindParam(':info',  $info,PDO::PARAM_STR);
		$re = $stmt->execute();
		if (!$re) {
			print_r($lin0);
			print_r($stmt->errorInfo());
			die("\n");
		} else $n2++;
	}
	fclose($h);
	print "\n$n2 items of '$f' file inserted.\n";
}
// // END:CARGA lawRepos


// falta registro dos metadados das evidencias...


// // // // // // // // // // // //
// //  BEGIN:CARGA docs
// INSERT de teste com as ~2mil amostras do SciELO-BR 
$stmt = $db->prepare( "SELECT oc.docs_upsert(:repo::text,:dtd::text,:pid::text,:xcontent::xml,NULL::JSON)" );
$pasta2 = "$pasta/samples";
$n=$n2=0;
foreach (scandir($pasta2) as $dtype) if (strlen($dtype)>2) {
	$pasta3 = "$pasta2/$dtype";
	foreach (scandir($pasta3) as $dft_repo) if (strlen($dft_repo)>2)
		foreach (scandir("$pasta3/$dft_repo") as $file) if (strlen($file)>2) {
			$n++;
			//print "\n--$n-- $pasta3 ($dft_repo) $file ";
			$pid = preg_replace('/\.xml/i','',$file);
			$f = "$pasta3/$dft_repo/$file";
			$cont = file_get_contents($f);
			if (!$cont) 
				die("\n-- empty file: $f");
			// check by fileaname for samples. 
			$stmt->bindParam(':repo',$dft_repo,PDO::PARAM_STR);

			$stmt->bindParam(':pid',$pid,PDO::PARAM_STR);

			$doctype = preg_match($rgx_doctype,$cont,$m)? $m[1]: '';
			$doctype = preg_replace('/\s+/s',' ',$doctype);
			if ($doctype) 
				$cont = preg_replace($rgx_doctype, '', $cont);
			$stmt->bindParam(':dtd',$doctype,PDO::PARAM_STR);

			// $stmt->bindParam(':conteudo',$XHEAD.$cont,PDO::PARAM_STR);
			$stmt->bindParam(':xcontent',$cont,PDO::PARAM_STR);

			$re = $stmt->execute();

			if (!$re) {
				print_r($stmt->errorInfo());
				die("\n-- ERROR at $file, not saved\n");
			}
		} // xml files
} // doc types

print "\n$n XML docs of '$dft_repo' inserted\n\n";
// // END:CARGA docs

?>
FIM


