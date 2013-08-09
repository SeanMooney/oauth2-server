<?php

//if (!class_exists('PDOWrapper')) require_once __DIR__."/PDOWrapper.php";

namespace League\OAuth2\Server\Storage\PDO;

use League\OAuth2\Server\Storage\ScopeInterface;

class Scope implements ScopeInterface
{
    public function getScope($scope, $clientId = null, $grantType = null)
    {
        $args = \PDOWrapper::cleanseNullOrWrapStr($scope);
        
        if($result = \PDOWrapper::call("oauthGetScope", $args)) {
            $result = $result[0];
            return array(
                'id' =>  $result['id'],
                'scope' =>  $result['scope'],
                'name'  =>  $result['name'],
                'description'  =>  $result['description']
            );
        } else {
            return false;
        }
    }
}