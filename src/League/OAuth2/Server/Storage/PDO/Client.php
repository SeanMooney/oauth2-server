<?php

//if (!class_exists('PDOWrapper')) require_once __DIR__."/PDOWrapper.php";

namespace League\OAuth2\Server\Storage\PDO;

use League\OAuth2\Server\Storage\ClientInterface;

class Client implements ClientInterface
{
    public function getClient($clientId, $clientSecret = null, $redirectUri = null, $grantType = null)
    {        
        $args = \PDOWrapper::cleanseNull($clientId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($clientSecret)
                .",".\PDOWrapper::cleanseNullOrWrapStr($redirectUri);
        
        if($result = PDOWrapper::call("oauthGetClient", $args)) {
            $result = $result[0];
            return array(
                'client_id' =>  $result['id'],
                'client_secret' =>  $result['secret'],
                'redirect_uri'  =>  (isset($result['redirect_uri'])) ? $result['redirect_uri'] : null,
                'name'  =>  $result['name']
            );
        } else {
            return false;
        }
    }
}