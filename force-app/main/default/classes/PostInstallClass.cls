global class PostInstallClass implements InstallHandler {
    private static final String AUTH_PROVIDER_LABEL = 'Marketing_Cloud';
    private static final String AUTH_PROVIDER_NAME = 'Marketing_Cloud';

    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            // New installation (not a package upgrade)

            authProvider[] provider = [ SELECT Id FROM authProvider WHERE DeveloperName = :AUTH_PROVIDER_NAME ];
            if (provider.size() == 0) {
                // Auth Provider doesn't exist, create it

                // Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                // Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                // customMetadata.fullName = 'mktcloudlabs__authProvider.Marketing_Cloud_1';

                // Metadata.CustomMetadataValue friendlyName = new Metadata.CustomMetadataValue();
                // friendlyName.field = 'friendlyName';
                // friendlyName.value = 'Marketing_Cloud_1';
                // customMetadata.values.add(friendlyName);

                // Metadata.CustomMetadataValue consumerKey = new Metadata.CustomMetadataValue();
                // consumerKey.field = 'consumerKey';
                // consumerKey.value = 'CONSUMER_KEY';
                // customMetadata.values.add(consumerKey);

                // Metadata.CustomMetadataValue consumerSecret = new Metadata.CustomMetadataValue();
                // consumerSecret.field = 'consumerSecret';
                // consumerSecret.value = 'CONSUMER_SECRET';
                // customMetadata.values.add(consumerSecret);

                // Metadata.CustomMetadataValue authorizeUrl = new Metadata.CustomMetadataValue();
                // authorizeUrl.field = 'authorizeUrl';
                // authorizeUrl.value = 'https://quip.com/authorize';
                // customMetadata.values.add(authorizeUrl);

                // Metadata.CustomMetadataValue tokenUrl = new Metadata.CustomMetadataValue();
                // tokenUrl.field = 'tokenUrl';
                // tokenUrl.value = 'https://quip.com/authorize';
                // customMetadata.values.add(tokenUrl);

                // Metadata.CustomMetadataValue providerType = new Metadata.CustomMetadataValue();
                // providerType.field = 'providerType';
                // providerType.value = 'OpenIdConnect';
                // customMetadata.values.add(providerType);

                // mdContainer.addMetadata(customMetadata);
                // Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
                // System.debug(jobId);
            }
        }
    }
}
