<?php

//if (!class_exists('PDOWrapper')) require_once __DIR__."/PDOWrapper.php";

namespace League\OAuth2\Server\Storage\PDO;

use League\OAuth2\Server\Storage\SessionInterface;

class Session implements SessionInterface
{
    public function createSession($clientId, $ownerType, $ownerId)
    {
        $args = \PDOWrapper::cleanseNull($clientId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($ownerType)
                .",".\PDOWrapper::cleanseNull($ownerId);
        
        if($result = \PDOWrapper::call("oauthCreateSession", $args)) {
             return $db->lastInsertId();
        } else {
            return false;
        }
    }

    public function deleteSession($clientId, $ownerType, $ownerId)
    {
        $args = \PDOWrapper::cleanseNull($clientId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($ownerType)
                .",".\PDOWrapper::cleanseNull($ownerId);
        
        \PDOWrapper::call("oauthDeleteSession", $args);
    }

    public function associateRedirectUri($sessionId, $redirectUri)
    {
        $args = \PDOWrapper::cleanseNull($sessionId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($redirectUri);
        
       \PDOWrapper::call("oauthAssociateRedirectUri", $args);
    }

    public function associateAccessToken($sessionId, $accessToken, $expireTime)
    {      
        $args = \PDOWrapper::cleanseNull($sessionId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($accessToken)
                .",".\PDOWrapper::cleanseNull($expireTime);
        
        if($result = \PDOWrapper::call("oauthAssociateAccessToken", $args)) {
             return $db->lastInsertId();
        } else {
            return false;
        }
    }

    public function associateRefreshToken($accessTokenId, $refreshToken, $expireTime, $clientId)
    {       
        $args = \PDOWrapper::cleanseNull($accessTokenId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($refreshToken)
                .",".\PDOWrapper::cleanseNull($expireTime)
                .",".\PDOWrapper::cleanseNull($clientId);
        
        \PDOWrapper::call("oauthAssociateRefreshToken", $args);
    }

    public function associateAuthCode($sessionId, $authCode, $expireTime)
    {        
        $args = \PDOWrapper::cleanseNull($sessionId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($authCode)
                .",".\PDOWrapper::cleanseNull($expireTime);
        
        if($result = \PDOWrapper::call("oauthAssociateAuthCode", $args)) {
             return $db->lastInsertId();
        }
    }

    public function removeAuthCode($sessionId)
    {       
        $args = \PDOWrapper::cleanseNull($sessionId);
        \PDOWrapper::call("oauthRemoveAuthCode", $args);
    }

    public function validateAuthCode($clientId, $redirectUri, $authCode)
    {       
        $args = \PDOWrapper::cleanseNull($clientId)
                .",".\PDOWrapper::cleanseNullOrWrapStr($redirectUri)
                .",".\PDOWrapper::cleanseNullOrWrapStr($authCode);
        
        if($result = \PDOWrapper::call("oauthValidateAuthCode", $args)) {
             return $result[0];
        } else {
            return false;
        }
    }

    public function validateAccessToken($accessToken)
    {
        $args = \PDOWrapper::cleanseNullOrWrapStr($accessToken);
        
        if($result = \PDOWrapper::call("oauthValidateAccessToken", $args)) {
             return $result[0];
        } else {
            return false;
        }
    }

    public function removeRefreshToken($refreshToken)
    {      
        $args = \PDOWrapper::cleanseNullOrWrapStr($refreshToken);        
        \PDOWrapper::call("oauthRemoveRefreshToken", $args);
    }

    public function validateRefreshToken($refreshToken, $clientId)
    {
        $args = \PDOWrapper::cleanseNullOrWrapStr($refreshToken)
                .",".\PDOWrapper::cleanseNull($clientId);
        
        if($result = \PDOWrapper::call("oauthValidateRefreshToken", $args)) {
             return $result[0]['session_access_token_id'];
        } else {
            return false;
        }    
    }

    public function getAccessToken($accessTokenId)
    {
        $args = \PDOWrapper::cleanseNull($accessTokenId);
        
        if($result = \PDOWrapper::call("oauthGetAccessToken", $args)) {
             return $result[0];
        } else {
            return false;
        }  
    }

    public function associateAuthCodeScope($authCodeId, $scopeId)
    {
        $args = \PDOWrapper::cleanseNull($authCodeId)
                .",".\PDOWrapper::cleanseNull($scopeId);
        
        \PDOWrapper::call("oauthAssociateAuthCodeScope", $args);
    }

    public function getAuthCodeScopes($oauthSessionAuthCodeId)
    {
        $args = \PDOWrapper::cleanseNull($oauthSessionAuthCodeId);
        
        if($result = \PDOWrapper::call("oauthGetAuthCodeScopes", $args)) {
             return $result[0]; // fetchAll() - PDO
        } else {
            return false; 
        } 
    }

    public function associateScope($accessTokenId, $scopeId)
    {
        $args = \PDOWrapper::cleanseNull($accessTokenId)
                .",".\PDOWrapper::cleanseNull($scopeId);
        
        \PDOWrapper::call("oauthAssociateScope", $args);
    }

    public function getScopes($accessToken)
    {
        $args = \PDOWrapper::cleanseNullOrWrapStr($accessToken);
        
        if($result = \PDOWrapper::call("oauthGetScopes", $args)) {
             return $result[0]; // fetchAll() - PDO
        } else {
            return array();
        }  
    }
}