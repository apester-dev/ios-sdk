//
//  ScreenArticles.swift
//  ApesterTestApp
//
//  Created by Michael Krotorio on 1/7/24.
//

import Foundation
import ApesterKit
// The function to fill the array with dictionaries
func fillTheArray(unitTypes: [(type: UnitType, unitParam: APEUnitParams)]) -> [[Category: ScreenContent]] {
    var screenContent = [[Category: ScreenContent]]()

    for (idx, (type, unitParam)) in unitTypes.enumerated() {
        let content = ScreenContent(unitType: type, mediaId: unitParam.id , article: getArticleForIndex(idx))
        let category = getCategoryForIndex(idx)
        screenContent.append([category: content])
    }

    return screenContent
}
func getIndexFofrCategoryAndType(category: Category, unitType: UnitType ) -> Int{
    let categorySum = category == Category.lifestyle ? 0 : category == Category.news ? 3 : 6
    let unitSum = unitType == UnitType.Quiz ? 0 : unitType == UnitType.Story ? 1 : 2
    return categorySum + unitSum
}

func getCategoryForIndex(_ index: Int) -> Category {
    switch index {
    case 0...2:
        return .lifestyle
    case 3...5:
        return .news
    case 6...8:
        return .sports
    default:
        return .lifestyle // Default case
    }
}

func getArticleForIndex(_ index: Int) -> Article {
    switch index {
    case 0:
        return Article(
            title: "Behind the Stage Names: The Real Identities of Famous Singers and Actors",
            topArticle: "Many celebrated singers and actors are better known by their stage names, creating a mystique around their true identities. Lady Gaga, born Stefani Joanne Angelina Germanotta, is a prime example, having crafted a unique persona that's as memorable as her music. Similarly, the magnetic Elton John was born Reginald Kenneth Dwight.",
            bottomArticle: "His stage name mirrors his larger-than-life stage presence. Iconic rapper Jay-Z, known for his impactful lyrics, was born Shawn Corey Carter. His stage name has become synonymous with hip-hop royalty. The illustrious actress Whoopi Goldberg, born Caryn Elaine Johnson, chose a name that would stand out in Hollywood, and it certainly has. These artists' choices in stage names have become integral parts of their public identities, contributing significantly to their fame and recognition."
        )
    case 1:
        return Article(
            title: "Indulgence and Serenity: A Journey Through Luxurious Spa Days",
            topArticle: "Embark on a journey of relaxation and opulence with a luxurious spa day. From thermal baths surrounded by nature's beauty to exclusive treatments using the finest organic ingredients, a luxurious spa experience offers a sanctuary for the senses. Picture yourself unwinding in a tranquil environment, where every detail is curated for utmost comfort and serenity.",
            bottomArticle: "Indulge in a range of treatments – from rejuvenating facials that leave your skin glowing to deep tissue massages that ease every tension. Discover the wonders of aromatherapy, hot stone therapy, or a traditional hammam experience. Luxurious spas also offer a variety of wellness activities like yoga and meditation, ensuring a holistic approach to relaxation. This retreat is not just about pampering; it's an opportunity to disconnect from the outside world and reconnect with your inner self in a setting of sheer luxury."
        )
    case 2:
        return Article(
            title: "Echoes of Rhymes: The Ultimate Showdown in Rap Battles",
            topArticle: """
            In the world of rap battles, lyricism and stage presence merge into a riveting display of verbal prowess. Each rapper, armed with quick wit and creativity, steps up to deliver punchlines and metaphors, captivating the audience. These battles, more than a competition of flow and rhythm, are a test of real-time ingenuity and the ability to resonate with the crowd.
            """,
            bottomArticle: """
            The ultimate rap battles embody the essence of hip-hop culture, serving as a platform for emerging talents and seasoned veterans to etch their voices in history. They're not just contests of skill but celebrations of diversity and unity within the rap community, inspiring new generations of artists in this dynamic musical arena.
            """
        )
    case 3:
        return Article(
            title: "Exploring the White House: A Quiz on America's Presidential Home",
            topArticle: "The White House, an iconic symbol of the American presidency, holds a rich history and many secrets. From its architectural wonders to the historical events it has witnessed, the White House is a source of fascination for many. Did you know that the White House has 132 rooms and 35 bathrooms, or that it was rebuilt after being burned down in 1814?",
            bottomArticle: "This quiz will take you on a journey through the White House's storied past, testing your knowledge on everything from its architectural features to the presidential events it has hosted. Are you ready to explore the mysteries of America's most famous residence?"
        )
    case 4:
        return Article(
            title: "Joe Biden's Top Promises: A Review of the President's Key Commitments",
            topArticle: "Since taking office, President Joe Biden has outlined a series of ambitious promises aimed at addressing some of the nation's most pressing challenges. Among his top commitments are tackling the COVID-19 pandemic, economic recovery, climate change, and healthcare reform. Biden's approach to COVID-19 includes a nationwide vaccination campaign and renewed international cooperation.",
            bottomArticle: "His economic plan focuses on rebuilding the economy through large-scale infrastructure projects and support for American manufacturing. On climate change, Biden has re-entered the Paris Agreement and proposed green energy initiatives. In healthcare, his administration aims to expand the Affordable Care Act and reduce prescription drug costs. This story dives into the progress and challenges of these key promises."
        )
    case 5:
        return Article(
            title: "Biden vs Trump: Public Opinion on Presidential Policies",
            topArticle: "The political landscape of the United States has seen significant shifts with the transition from Donald Trump's administration to Joe Biden's. This has led to contrasting policies in areas such as foreign relations, immigration, environmental regulations, and healthcare. Trump's presidency was marked by hardline immigration policies, withdrawal from international agreements, and deregulation efforts.",
            bottomArticle: "Biden's tenure, on the other hand, focuses on more inclusive immigration reforms, re-engagement with global partners, and a strong emphasis on environmental protection and healthcare accessibility. This poll seeks to gauge public opinion on these changing policies and the impact of the presidential transition on national and international affairs."
        )
    case 6:
        return Article(
            title: "Lionel Messi: Test Your Knowledge of a Football Legend",
            topArticle: "Lionel Messi, regarded as one of the greatest footballers of all time, has an illustrious career filled with remarkable achievements. From his beginnings at Barcelona's famed La Masia to breaking numerous records, Messi's journey is nothing short of inspirational. How well do you know the legend?",
            bottomArticle: "This quiz challenges you to test your knowledge of Messi's career highlights, personal milestones, and memorable moments on the pitch. Do you know how many Ballon d'Or awards he's won, or the records he's set in La Liga and the Champions League? Take the quiz and find out!"
        )
    case 7:
        return Article(
            title: "The Exciting Realm of Tour de France: Champions and Heritage",
            topArticle: "The Tour de France has mesmerized fans for over a century, blending endurance, strategy, and the spirit of competition. It's a domain where legends such as Eddy Merckx, Bernard Hinault, and Miguel Indurain have become synonymous with excellence. Their grueling battles, historic victories, and unforgettable moments are permanently inscribed in the history of professional cycling.",
            bottomArticle: "Over the years, the Tour de France has transformed, adapting to technological advances and broadening its international appeal. Contemporary icons like Chris Froome, Tadej Pogačar, and Geraint Thomas carry on this rich tradition, demonstrating their extraordinary cycling skills and captivating audiences with their personal and team narratives. This story explores the heritage, development, and current dynamics of the Tour de France."
        )
    case 8:
        return Article(
            title: "WWE Fan Favorites: Cast Your Vote!",
            topArticle: "WWE's rich history is filled with iconic wrestlers who have left an indelible mark on the sport. From the charisma of The Rock to the dominance of Brock Lesnar, each superstar brings something unique to the ring. But who ranks as the all-time fan favorite?",
            bottomArticle: "In this poll, cast your vote for your favorite WWE superstar. Whether it's the technical prowess of Bret Hart, the showmanship of Ric Flair, or the sheer force of Andre the Giant, let your voice be heard. Who is the greatest WWE superstar in your eyes?"
        )
    default:
        return Article(
            title: "Default Title",
            topArticle: "Default Top Article",
            bottomArticle: "Default Bottom Article"
        )
    }
}

