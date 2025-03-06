Hi, ito steps for setting up github, very important na sundan step by step:

--Download Git--
1. -> Kapag wala kapang git na naka lagay sa pc mo; https://git-scm.com/downloads
2. -> kapag na install mo na yung .exe, punta ka 'System Properties' sa pc mo then 'Edit System Variables', pwede mo diretso search yan sa pc mo
3. -> Sa Environment Variables window, dun sa System variables, hanapin mo 'Path' then edit.
4. -> pindutin mo 'New' tapos lagay mo yung file path ng git na ininstall mo from the .exe; ganto itsura(C:\Program Files\Git\cmd)
5. -> to check, type mo sa cmd, 'git version'

--INITIALIZING--
1. -> Gawa ka github account kapag wala ka pa
2. -> after that, type mo to sa terminal ng visual studio

    git config --global user.email "you@example.com"
    git config --global user.name "Your UserName"

   -> palitan mo yung naka "" ng account mo sa github

3. -> Next type mo to sa search sa taas ng visual studio

    >Git: Clone 

   -> tapos type mo ito sa "Provide repository URL"

   https://github.com/Pixlpages/SE_SourceCode.git

   -> Select ka ng location kung saan mo gusto save yung repo

--Committing--

4. -> Dapat lumabas na sa explorer mo yung files

5. -> assuming na nag edit ka na ng files, pindutin mo Source Control sa side bar (ctrl+shift+g)
    diyan pwede ka na mag commit(need ng message bago commit) at mag push and pull

    -> Under ng BIG BLUE COMMIT BUTTON, andiyan yung summary ng changes mong ginawa,
         pindutin mo muna 'Stage Changes' sa "Changes" (yun yung plus+ button kapag highlighted yung file)
    -> tapos tsaka ka maglagay commit message(REQUIRED) tas pindutin mo commit
    -> tapos push and sync


    --IMPORTANT--

    -> mag sync changes ka muna kapag may nabago sa repository
    -> kapag may problema sabihin mo lang sa GC


    PUSH - kapag iuupdate mo yung nasa github
    PULL - kapag kukunin mo yung nasa github

   
