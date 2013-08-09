CREATE TABLE IF NOT EXISTS `oauth_clients` (
  `id` INT unsigned NOT NULL,
  `secret` char(128) COLLATE utf8_unicode_ci NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `auto_approve` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_oacl_clse_clid` (`secret`,`id`),
  CONSTRAINT `FK_oauth_clients_Users` FOREIGN KEY (`id`) REFERENCES `Users` (`id`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `FK_oauth_clients_Users_2` FOREIGN KEY (`secret`) REFERENCES `Users` (`password`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_client_endpoints` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int UNSIGNED NOT NULL,
  `redirect_uri` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `i_oaclen_clid` (`client_id`),
  CONSTRAINT `f_oaclen_clid` FOREIGN KEY (`client_id`) REFERENCES `oauth_clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_sessions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `client_id` int UNSIGNED NOT NULL,
  `owner_type` enum('user','client') NOT NULL DEFAULT 'user',
  `owner_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `i_uase_clid_owty_owid` (`client_id`,`owner_type`,`owner_id`),
  CONSTRAINT `f_oase_clid` FOREIGN KEY (`client_id`) REFERENCES `oauth_clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_access_tokens` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` int(10) unsigned NOT NULL,
  `access_token` char(40) NOT NULL,
  `access_token_expires` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_oaseacto_acto_seid` (`access_token`,`session_id`),
  KEY `f_oaseto_seid` (`session_id`),
  CONSTRAINT `f_oaseto_seid` FOREIGN KEY (`session_id`) REFERENCES `oauth_sessions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_authcodes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` int(10) unsigned NOT NULL,
  `auth_code` char(40) NOT NULL,
  `auth_code_expires` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `session_id` (`session_id`),
  CONSTRAINT `oauth_session_authcodes_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `oauth_sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_redirects` (
  `session_id` int(10) unsigned NOT NULL,
  `redirect_uri` varchar(255) NOT NULL,
  PRIMARY KEY (`session_id`),
  CONSTRAINT `f_oasere_seid` FOREIGN KEY (`session_id`) REFERENCES `oauth_sessions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_refresh_tokens` (
  `session_access_token_id` int(10) unsigned NOT NULL,
  `refresh_token` char(40) NOT NULL,
  `refresh_token_expires` int(10) unsigned NOT NULL,
  `client_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`session_access_token_id`),
  KEY `client_id` (`client_id`),
  CONSTRAINT `oauth_session_refresh_tokens_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `oauth_clients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `f_oasetore_setoid` FOREIGN KEY (`session_access_token_id`) REFERENCES `oauth_session_access_tokens` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_scopes` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `scope` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_oasc_sc` (`scope`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_token_scopes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `session_access_token_id` int(10) unsigned DEFAULT NULL,
  `scope_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `u_setosc_setoid_scid` (`session_access_token_id`,`scope_id`),
  KEY `f_oasetosc_scid` (`scope_id`),
  CONSTRAINT `f_oasetosc_scid` FOREIGN KEY (`scope_id`) REFERENCES `oauth_scopes` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `f_oasetosc_setoid` FOREIGN KEY (`session_access_token_id`) REFERENCES `oauth_session_access_tokens` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `oauth_session_authcode_scopes` (
  `oauth_session_authcode_id` int(10) unsigned NOT NULL,
  `scope_id` smallint(5) unsigned NOT NULL,
  KEY `oauth_session_authcode_id` (`oauth_session_authcode_id`),
  KEY `scope_id` (`scope_id`),
  CONSTRAINT `oauth_session_authcode_scopes_ibfk_2` FOREIGN KEY (`scope_id`) REFERENCES `oauth_scopes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `oauth_session_authcode_scopes_ibfk_1` FOREIGN KEY (`oauth_session_authcode_id`) REFERENCES `oauth_session_authcodes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- Dumping structure for procedure debug-test3.oauthAssociateAccessToken
DROP PROCEDURE IF EXISTS `oauthAssociateAccessToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateAccessToken`(IN `sessionId` INT, IN `accessToken` CHAR(40), IN `accessTokenExpires` INT)
BEGIN
	INSERT INTO oauth_session_access_tokens (session_id, access_token, access_token_expires)
         VALUE (sessionId, accessToken, accessTokenExpires);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthAssociateAuthCode
DROP PROCEDURE IF EXISTS `oauthAssociateAuthCode`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateAuthCode`(IN `sessionId` INT, IN `authCode` CHAR(40), IN `AuthCodeExpires` INT)
BEGIN
	INSERT INTO oauth_session_authcodes (session_id, auth_code, auth_code_expires)
         VALUE (sessionId, authCode, authCodeExpires);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthAssociateAuthCodeScope
DROP PROCEDURE IF EXISTS `oauthAssociateAuthCodeScope`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateAuthCodeScope`(IN `authCodeId` INT, IN `scopeId` SMALLINT)
BEGIN
	INSERT INTO `oauth_session_authcode_scopes` (`oauth_session_authcode_id`, `scope_id`) VALUES (authCodeId, scopeId);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthAssociateRedirectUri
DROP PROCEDURE IF EXISTS `oauthAssociateRedirectUri`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateRedirectUri`(IN `sessionId` INT, IN `redirectUri` VARCHAR(255))
BEGIN
	INSERT INTO oauth_session_redirects (session_id, redirect_uri) VALUE (sessionId, redirectUri);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthAssociateRefreshToken
DROP PROCEDURE IF EXISTS `oauthAssociateRefreshToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateRefreshToken`(IN `accessTokenId` INT, IN `refreshToken` CHAR(40), IN `expireTime` INT, IN `clientId` INT)
BEGIN
	INSERT INTO oauth_session_refresh_tokens (session_access_token_id, refresh_token, refresh_token_expires, client_id) VALUE
	         (accessTokenId, refreshToken, expireTime, clientId);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthAssociateScope
DROP PROCEDURE IF EXISTS `oauthAssociateScope`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthAssociateScope`(IN `accessTokenId` INT, IN `scopeId` SMALLINT)
BEGIN
	INSERT INTO `oauth_session_token_scopes` (`session_access_token_id`, `scope_id`)
	         VALUE (accessTokenId, scopeId);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthCreateSession
DROP PROCEDURE IF EXISTS `oauthCreateSession`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthCreateSession`(IN `clientId` INT, IN `ownerType` ENUM('user','client'), IN `ownerId` VARCHAR(255))
BEGIN
	INSERT INTO oauth_sessions (client_id, owner_type,  owner_id) VALUE (clientId, ownerType, ownerId);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthDeleteSession
DROP PROCEDURE IF EXISTS `oauthDeleteSession`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthDeleteSession`(IN `clientId` INT, IN `ownerType` ENUM('user','client'), IN `ownerId` VARCHAR(255))
BEGIN
	DELETE FROM oauth_sessions WHERE client_id = clientId AND owner_type = ownerType AND owner_id = ownerId;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthGetAccessToken
DROP PROCEDURE IF EXISTS `oauthGetAccessToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthGetAccessToken`(IN `accessTokenId` INT)
BEGIN
	if accessTokenId='' then set accessTokenId=null;end if;
	SELECT * FROM `oauth_session_access_tokens` WHERE `id` = accessTokenId;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthGetAuthCodeScopes
DROP PROCEDURE IF EXISTS `oauthGetAuthCodeScopes`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthGetAuthCodeScopes`(IN `oauthSessionAuthCodeId` INT)
BEGIN
	SELECT scope_id FROM `oauth_session_authcode_scopes` WHERE oauth_session_authcode_id = oauthSessionAuthCodeId;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthGetClient
DROP PROCEDURE IF EXISTS `oauthGetClient`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthGetClient`(IN `clientId` INT, IN `clientSecret` CHAR(128), IN `redirectUri` VARCHAR(255))
BEGIN
	if clientId='' then set clientId=null;end if;
	if clientSecret='' then set clientSecret=null;end if;
	if redirectUri='' then set redirectUri=null;end if;
	
	SELECT oc.id, oc.secret, oce.redirect_uri, oc.name FROM oauth_clients oc LEFT JOIN oauth_client_endpoints oce ON oce.client_id = oc.id WHERE isNullOrEqual(oc.id,clientId) AND isNullOrEqual(oce.redirect_uri,redirectUri);	
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthGetScope
DROP PROCEDURE IF EXISTS `oauthGetScope`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthGetScope`(IN `scope` VARCHAR(255))
BEGIN
	IF scope = '' THEN SET scope = null; END IF;
	SELECT * FROM oauth_scopes os WHERE isNullOrEqual(os.scope,scope);
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthGetScopes
DROP PROCEDURE IF EXISTS `oauthGetScopes`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthGetScopes`(IN `accessToken` CHAR(40))
BEGIN
	if accessToken='' then set accessToken=null;end if;
	SELECT oauth_scopes.* FROM oauth_session_token_scopes JOIN oauth_session_access_tokens ON oauth_session_access_tokens.`id` = `oauth_session_token_scopes`.`session_access_token_id` JOIN oauth_scopes ON oauth_scopes.id = `oauth_session_token_scopes`.`scope_id` WHERE access_token = accessToken;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthRemoveAuthCode
DROP PROCEDURE IF EXISTS `oauthRemoveAuthCode`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthRemoveAuthCode`(IN `sessionId` INT)
BEGIN
	DELETE FROM oauth_session_authcodes WHERE session_id = sessionId;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthRemoveRefreshToken
DROP PROCEDURE IF EXISTS `oauthRemoveRefreshToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthRemoveRefreshToken`(IN `refreshToken` CHAR(40))
BEGIN
	DELETE FROM `oauth_session_refresh_tokens` WHERE refresh_token = refreshToken;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthValidateAccessToken
DROP PROCEDURE IF EXISTS `oauthValidateAccessToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthValidateAccessToken`(IN `accessToken` CHAR(40))
BEGIN
	SELECT session_id, oauth_sessions.`client_id`, oauth_sessions.`owner_id`, oauth_sessions.`owner_type` FROM `oauth_session_access_tokens` JOIN oauth_sessions ON oauth_sessions.`id` = session_id WHERE  access_token = accessToken AND access_token_expires >= UNIX_TIMESTAMP(NOW());
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthValidateAuthCode
DROP PROCEDURE IF EXISTS `oauthValidateAuthCode`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthValidateAuthCode`(IN `clientId` INT, IN `redirectUri` VARCHAR(255), IN `authCode` CHAR(40))
BEGIN
	SELECT oauth_sessions.id AS session_id, oauth_session_authcodes.id AS authcode_id
	         FROM oauth_sessions JOIN oauth_session_authcodes ON oauth_session_authcodes.`session_id`
	          = oauth_sessions.id JOIN oauth_session_redirects ON oauth_session_redirects.`session_id`
	          = oauth_sessions.id WHERE oauth_sessions.client_id = clientId AND oauth_session_authcodes.`auth_code`
	          = authCode AND  `oauth_session_authcodes`.`auth_code_expires` >= UNIX_TIMESTAMP(NOW()) AND
	           `oauth_session_redirects`.`redirect_uri` = redirectUri;
END//
DELIMITER ;


-- Dumping structure for procedure debug-test3.oauthValidateRefreshToken
DROP PROCEDURE IF EXISTS `oauthValidateRefreshToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `oauthValidateRefreshToken`(IN `refreshToken` INT, IN `clientId` INT)
BEGIN
	SELECT session_access_token_id FROM `oauth_session_refresh_tokens` WHERE
	         refresh_token = refreshToken AND client_id = clientId AND refresh_token_expires >= UNIX_TIMESTAMP(NOW());
END//
DELIMITER ;

-- Dumping structure for procedure debug-test3.getUserByOAuthToken
DROP PROCEDURE IF EXISTS `getUserByOAuthToken`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByOAuthToken`(IN `token` CHAR(40))
BEGIN	
	IF EXISTS(SELECT 1 FROM oauth_session_access_tokens o WHERE o.access_token = token) THEN
		set @userId = null;
 		SELECT client_id INTO @userId FROM oauth_sessions os WHERE os.id = (SELECT o.session_id FROM oauth_session_access_tokens o WHERE o.access_token = token);
		call getUser(@userId,null,null,null,null,null,null,null,null);
	END IF;
END//
DELIMITER ;


-- Triggers

-- Dumping structure for trigger debug-test3.onDeleteFromRegisteredUsers
DROP TRIGGER IF EXISTS `onDeleteFromRegisteredUsers`;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `onDeleteFromRegisteredUsers` AFTER DELETE ON `RegisteredUsers` FOR EACH ROW BEGIN
	INSERT INTO oauth_clients (id, secret, name) SELECT id, `password`, `display-name` FROM Users WHERE id = old.user_id;
END//
DELIMITER ;
SET SQL_MODE=@OLD_SQL_MODE;