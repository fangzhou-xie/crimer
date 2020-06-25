crimer
================
Fangzhou Xie

This `crimer` package wraps around the [FBI Crime Data Explorer
API](https://github.com/fbi-cde/crime-data-frontend). The package name
is coined by `crime` and `r`, and thus suggests that it will interact
with crime data within R.

## Installation

    devtools::install_github("mark-fangzhou-xie/crimer")

## Usage of CDE API and `crimer` package

Before we delve into the usage of `crimer`, it worth affording a detour
to take a look at the FBI Crime Data Explorer API (CDE hereafter)
itself.

### CDE API

The base url for this API is: `https://api.usa.gov/crime/fbi/sapi`.

And the usage of this API is:
`https://api.usa.gov/crime/fbi/sapi/{desired_endpiont}?api_key=<API_KEY>`.

Here, `{desired_endpiont}` is a place-holder for some keywords that will
allow you to interact with API (i.e. getting data you want). They are
called “endpoints”, and are defined
[here](https://crime-data-explorer.fr.cloud.gov/api).

And `<API_KEY>` is a token that you should sign up by the following link
<https://api.data.gov/signup/>. This token will allow you to request
data from their API and it is free.

You can also refer to their official repo
[here](https://github.com/fbi-cde/crime-data-frontend).

## Usage of `crimer` package

### Set up environment for API key

Now that’s talk about how to use `crimer`. Before using it, you should
have signed up the API key from above. Then open your RStudio and type
the following in your console:

    file.edit("~/.Renviron")

and add the following line in the opened window:

    CRIMER_APIKEY="YOUR_API_KEY"

Obviously, you should replace whatever key you have between the
quotation mark.

Then you will need to save the file, and restart your RStudio.

Here, you may want to ask: why do we need to use the key in such a weird
way, instead of providing it directly to functions we have? Although you
are tempted to do so, it also means that your registered API key will be
kept inside the script you write. Once you need to distribute your codes
to others or to publish online, it could be misused by other people and
it is not safe to do so.

So, following `crminer`, (a package which bears a similar name but
serves a different purpose, [link
here](https://github.com/ropensci/crminer#just-crm_links-function-register-for-the-polite-pool)),
you need to edit the system environment and put your key there. `crimer`
package will read your API key through environment variables.

### `get_url()` function

The most basic and generic function is `get_url` and it only takes one
argument: `endpoint`.

As discussed above, there are only two things that we could play with in
the API url: `endpoint` and `api_key`. Since we have placed the API key
as an environment variable, then the only thing we could do is just
providing an `endpoint` string. And here you have the `get_url`
function.

    agencies <- get_url("api/agencies/list")

With this function at hand, you can basically get everything from this
FBI CDE API, but you need to have a look on API definition and use the
correct endpoint for it.

### `get_agencies()` function

This is just an convenient function to get all agencies.

    # the following two are equivalent
    agencies <- get_url("api/agencies/list")
    agencies <- get_agencies()

In fact, `get_agencies()` is just `get_url("api/agencies/list")`.

If you read through `lookups-controller` section in the API endpoint
definition [webpage](https://crime-data-explorer.fr.cloud.gov/api), you
will find the endpoint we are using here (`api/agencies/list`) “Returns
List of Agencies utilized by CDE Endpoint”. “Agencies” are local law
enforcement branches and are identified by unique `ori` variable.

### `get_agency_crime()` function

Beyond the basic `get_url()` function, there is another function
provided by this package: `get_agency_crime()`. As its name suggests, it
will provide you agency-level Summary Reporting System (SRS) crime data.

> SRS data is the legacy format that provides aggregated counts of the
> reported crime offenses known to law enforcement by location.

    asny <- get_agency_crime("NY330SS00", since = 1985, until = 2018)

There are three parameters: `ori`, `since`, and `until` for this
function. `ori` refers to the identifier for an police agency (which
could be found by `get_agencies()` function).

You can pass a character vector as the first argument of this function
or simply use the default `NULL`, which will query for all agencies that
are available.

The result will be in `tibble::tibble` format.

## Warning\!

> The API was designed to provide as much information as possible in a
> usable format. However, the FBI still has some recommendations about
> how to interpret and display the data provided. The FBI strongly
> advises against using this data to do any sort of ranking or
> comparison among states or other entities. The exception being that it
> is appropriate to compare a city to its respective state, and that
> state to a national perspective. —
> <https://crime-data-explorer.fr.cloud.gov/api>

## License

This package is published under [MIT
license](https://opensource.org/licenses/MIT).
