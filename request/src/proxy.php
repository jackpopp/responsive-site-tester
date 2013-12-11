<?php namespace Request\Src;

use Exception;

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
	*	@return html page 
	*/
	public function requestPage()
	{
		$uri = $this->getURI();

		$ch = curl_init(); 
		// set url 
		curl_setopt($ch, CURLOPT_URL, $uri); 
		//return the transfer as a string 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
		// $output contains the output string 
		$result = curl_exec($ch);
		// close curl resource to free up system resources 
		curl_close($ch); 

		# force the base uri to be that of the request uri
		$result = '<base href='.$uri.' />'.$result;

		return $result;
	}
}