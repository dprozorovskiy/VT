/**
* @author: Dmitry Prozorovskiy
* @date: 25-Jan-19
* @description: Test for VT_D2_PostToChatter
**/

@IsTest
public class VT_D2_PostToChatterTest {

    @IsTest
    private static void doTest() {
        Account acc = new Account(Name = 'test');
        insert acc;

        VT_D2_PostToChatter.ChatterPostTemplate template = new VT_D2_PostToChatter.ChatterPostTemplate();
        template.targetId = UserInfo.getUserId();
        template.message = 'Test message @' + UserInfo.getUserId() + '@' + acc.Id + '@0123456789ABCDEFGH blah blah';
        VT_D2_PostToChatter.postToChatter(new List<VT_D2_PostToChatter.ChatterPostTemplate>{template});
    }
}