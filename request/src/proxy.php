<?php namespace Request\Src;

use Exception;

require_once __DIR__.'/../vendor/simple_html_dom.php';

class Proxy 
{
	private $URI;
	private $result;

	function __construct()
	{
		try{
			if (empty($_GET['uri']))
				throw new Exception("Please post a uri");

			$this->setURI($_GET['uri']);

			if ( ! filter_var($this->getURI(), FILTER_VALIDATE_URL, FILTER_FLAG_HOST_REQUIRED))
				throw new Exception("Please provide valid uri");	
			
		}
		catch (Exception $e){
			echo $e->getMessage();

		}
	}

	/**
	* Sets the URI property
	*
	*	@return $this
	*/

	public function setURI($URI)
	{
		$this->URI = $URI;
		return $this;
	}

	/**
	*	Gets the URI property
	*
	*	@return string
	*/

	public function getURI()
	{
		return $this->URI;
	}

	/**
	* Sets the result property
	*
	*	@return $this
	*/

	public function setResult($result)
	{
		$this->result = $result;
		return $this;
	}

	/**
	*	Gets the result property
	*
	*	@return html page
	*/

	public function getResult()
	{
		return $this->result;
	}

	/**
	*	Requests a webpage via curl using the uri thats been posted to the object
	*
	*	@param String $uri
	*	@return String $html
	*/
	
	public function requestPage($uri)
	{
		# curl request
		$ch = curl_init();  
		curl_setopt($ch, CURLOPT_URL, $uri); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
		$result = curl_exec($ch);
		curl_close($ch); 

		# force the base uri to be that of the request uri
		$html = $this->appendBaseUrl($result, $uri);

		# cache web page?
		# file_put_contents( 'temp.html', $result );
		# return file_get_contents('temp.html');

		return $html.'<script>parent.finishedLoad('.$_GET['index'].')</script>';
	}

	/**
	*	Append a base url with the head of a html 
	*	
	*	@param String $htmlString
	*	@param String $uri
	*	@return String $html
	*/

	public function appendBaseUrl($htmlString, $uri)
	{
		$html = new \simple_html_dom();
		$html->load($htmlString);

		try 
		{
			$head = $html->find('head', 0);
			$text = $head->innertext;
			$html->find('head', 0)->innertext = '<base href='.$uri.' />'.$text;
			return $html;
		}
		catch (Exception $e)
		{
			return $html;
		}	
	}
}