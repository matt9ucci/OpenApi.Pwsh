@{
	ExcludeRules = @(
		'PSAvoidUsingPositionalParameters'
		'PSUseShouldProcessForStateChangingFunctions'
	)

	Rules = @{
		'PSAvoidUsingCmdletAliases' = @{
			'allowlist' = @(
				'?' # Where-Object
				'%' # ForEach-Object
			)
		}
	}
}
