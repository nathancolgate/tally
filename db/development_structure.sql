CREATE TABLE `choices` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `poll_id` int(11) unsigned NOT NULL default '0',
  `position` int(11) unsigned NOT NULL default '0',
  `body` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `polls` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `author_id` int(11) unsigned NOT NULL default '0',
  `title` varchar(255) NOT NULL default '',
  `body` text,
  `replied_on_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `polls_tags` (
  `poll_id` int(11) NOT NULL default '0',
  `tag_id` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `replies` (
  `id` int(11) NOT NULL auto_increment,
  `poll_id` int(11) unsigned NOT NULL default '0',
  `user_id` int(11) unsigned NOT NULL default '0',
  `choice_id` int(11) unsigned NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `tag` varchar(32) NOT NULL default '',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(32) default NULL,
  `login` varchar(80) default NULL,
  `password` varchar(40) default NULL,
  `email` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `users_friends` (
  `user_id` int(11) NOT NULL default '0',
  `friend_id` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

