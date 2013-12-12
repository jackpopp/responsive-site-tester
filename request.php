<?php

require 'request/src/proxy.php';

use Request\Src\Proxy as Proxy;

$proxy = new Proxy();
echo $proxy->requestPage($proxy->getURI());