/**
* @author: Dmitry Prozorovskiy
* @date: 16-Jan-19
* @description: Post to Chatter as API user
**/

public without sharing class VT_D2_PostToChatter {
    public class ChatterPostTemplate {
        @InvocableVariable(Label = 'Target ID' Required = true)
        public Id targetId;

        @InvocableVariable(Label = 'Message' Required = true)
        public String message;
    }
    private class BatchCollectionInput {
        public List<BatchInput> inputs;
    }
    private class BatchInput {
        public RichInput richInput;
    }
    private class RichInput {
        RequestBody body;
        String feedElementType = 'FeedItem';
        String subjectId;
        public RichInput(Id targetId, String message) {
            this.body = new RequestBody();
            this.body.messageSegments = getSegmentsFromMessage(message);
            this.subjectId = targetId;
        }
    }

    private class RequestBody {
        List<BodySegment> messageSegments;
    }

    private class BodySegment {
        String type;
        String text;
        String id;
        String entityId;

        public BodySegment(String type, String value) {
            this.type = type;
            switch on type {
                when 'Text' {
                    this.text = value;
                }
                when 'Mention' {
                    this.id = value;
                }
                when 'EntityLink' {
                    this.entityId = value;
                }
            }
        }
    }

    @InvocableMethod
    public static void postToChatter(List<ChatterPostTemplate> templates) {
        if (System.isFuture() || System.isBatch() || System.isQueueable()) {
            doChatterPost(templates);
        } else {
            doChatterPostFuture(JSON.serialize(templates));
        }
    }
    private static void postToChatter(Id targetId, String message) {
        ChatterPostTemplate template = new ChatterPostTemplate();
        template.targetId = targetId;
        template.message = message;
        doChatterPost(new List<ChatterPostTemplate>{template});
    }

    @Future(Callout=true)
    private static void doChatterPostFuture(String templatesJSON) {
        List<ChatterPostTemplate> templates = (List<ChatterPostTemplate>)JSON.deserialize(templatesJSON, List<ChatterPostTemplate>.class);
        doChatterPost(templates);
    }
    
    private static void doChatterPost(List<ChatterPostTemplate> templates) {
        String endpoint = VTD1_FileUploadUserCredentials__c.getInstance().org_url__c +
            '/services/data/v44.0/chatter/feed-elements/batch';
        List<BatchInput> batchInputsList = new List<BatchInput>();
        for(ChatterPostTemplate template : templates) {
            BatchInput batchInput = new BatchInput();
            // fix for BR() function in process builder formula
            template.message =  template.message.replace('_BR_ENCODED_','\n');
            batchInput.richInput = new RichInput(template.targetId, template.message);
            batchInputsList.add(batchInput);
        }
        BatchCollectionInput batchCollectionInput = new BatchCollectionInput();
        batchCollectionInput.inputs = batchInputsList;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + VT_D1_HelperClass.getSessionIdForGuest());
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(batchCollectionInput, true));
        req.setTimeout(120000);
        req.setEndpoint(endpoint);

        system.debug(req);

        if (! Test.isRunningTest()) {
            HttpResponse res = new Http().send(req);
            system.debug(res.getBody());
        }
    }

    private static List<BodySegment> getSegmentsFromMessage (String message) {
        Pattern compiledPattern = Pattern.compile('@([0-9a-zA-Z]{18})');
        Matcher matcher = compiledPattern.matcher(message);
        Integer idx = 0;
        List<BodySegment> segments = new List<BodySegment>();

        while (matcher.find()) {
            if (idx < matcher.start()) {
                segments.add(new BodySegment(
                    'Text',
                    message.substring(idx, matcher.start())
                ));
            }

            String potentialId = message.substring(matcher.start() + 1, matcher.end());
            if (potentialId instanceof Id) {
                Id recId = (Id)potentialId;
                segments.add(new BodySegment(
                    recId.getSobjectType() == User.getSObjectType() ? 'Mention' : 'EntityLink',
                    recId
                ));
            } else {
                segments.add(new BodySegment(
                    'Text',
                    '@' + potentialId
                ));
            }
            
            idx = matcher.end();
        }

        if (idx < message.length()) {
            segments.add(new BodySegment(
                'Text',
                message.substring(idx, message.length())
            ));
        }

        return segments;
    }
}